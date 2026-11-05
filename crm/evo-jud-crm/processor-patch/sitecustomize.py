"""evo-jud-crm: áudio do WhatsApp nos agentes do evo-ai-processor (ADK 1.19 + LiteLLM 1.68).

Problema: o ADK converte áudio em {"type": "audio_url"}, que o LiteLLM 1.68 recusa em
qualquer provedor ("invalid content type"). O turno inteiro vira erro 500 ("Tive uma
instabilidade") e, como o áudio fica gravado na sessão, toda mensagem seguinte da mesma
conversa também falha.

Correção (só na montagem da requisição; a sessão gravada não é alterada):
- modelos OpenAI (gpt-4o-mini etc.): o áudio é transcrito com a mesma chave do agente
  (gpt-4o-mini-transcribe, com whisper-1 de reserva) e entra como texto. A transcrição fica
  em cache pelo hash do arquivo, porque o histórico reenvia o mesmo áudio a cada turno;
- modelo Gemini: o áudio vai como {"type": "file"} (o Gemini ouve nativamente);
  "audio/opus" e "audio/ogg; codecs=opus" (nota de voz do WhatsApp) viram "audio/ogg";
- se não der para transcrever (formato não aceito, falha da API, outro provedor), o áudio
  vira um aviso para o agente pedir ao cliente que escreva. O turno nunca quebra.

Segundo problema: o ADK descarta do histórico toda mensagem cuja PRIMEIRA parte é texto
vazio (contents._contains_empty_content). Áudio, imagem ou documento enviados sem legenda
chegam assim e sumiam: o agente respondia como se nada tivesse sido enviado. O patch
mantém essas mensagens quando há anexo e tira a parte de texto vazia antes de enviar.

Montado como sitecustomize.py no site-packages do contêiner do processor. Se o ADK mudar
e o patch não se aplicar, só registra um aviso e o processor sobe normalmente.
"""
import collections
import hashlib
import logging

_log = logging.getLogger("evojud.audio_patch")

AVISO_SEM_AUDIO = (
    "[O cliente enviou uma mensagem de áudio que não pôde ser ouvida. "
    "Peça com gentileza que ele escreva a mensagem.]"
)
PREFIXO_TRANSCRICAO = "[Mensagem de áudio do cliente, transcrita automaticamente]: "

# Formatos aceitos pela transcrição da OpenAI, pela extensão do nome do arquivo.
_EXT_TRANSCRICAO = {
    "audio/ogg": "ogg", "audio/opus": "ogg", "audio/mpeg": "mp3", "audio/mp3": "mp3",
    "audio/wav": "wav", "audio/wave": "wav", "audio/x-wav": "wav", "audio/mp4": "m4a",
    "audio/x-m4a": "m4a", "audio/aac": "m4a", "audio/webm": "webm", "audio/flac": "flac",
    "audio/x-flac": "flac",
}
_cache: "collections.OrderedDict[str, str]" = collections.OrderedDict()
_CACHE_MAX = 500


def _base(mime: str) -> str:
    return mime.split(";")[0].strip().lower()


def _mime_gemini(mime: str) -> str:
    b = _base(mime)
    return "audio/ogg" if b in ("audio/opus", "audio/ogg") else b


def _eh_openai(modelo: str) -> bool:
    return "/" not in modelo or modelo.startswith("openai/")


async def _transcrever(data: bytes, mime: str, api_key: str):
    ext = _EXT_TRANSCRICAO.get(_base(mime))
    if not ext or not api_key or not data:
        return None
    h = hashlib.sha256(data).hexdigest()
    if h in _cache:
        _cache.move_to_end(h)
        return _cache[h]
    from openai import AsyncOpenAI

    cliente = AsyncOpenAI(api_key=api_key, timeout=60)
    for modelo in ("gpt-4o-mini-transcribe", "whisper-1"):
        try:
            r = await cliente.audio.transcriptions.create(
                model=modelo, file=(f"audio.{ext}", data, f"audio/{ext}"), language="pt")
            texto = (getattr(r, "text", "") or "").strip()
            _cache[h] = texto
            while len(_cache) > _CACHE_MAX:
                _cache.popitem(last=False)
            _log.warning("evo-jud audio patch: áudio transcrito (%s, %d bytes)", modelo, len(data))
            return texto
        except Exception as e:  # tenta o próximo modelo
            _log.warning("evo-jud audio patch: transcrição falhou com %s: %s", modelo, str(e)[:200])
    return None


def _parte_vazia(p) -> bool:
    return (p.text == "" and not p.inline_data and not p.file_data
            and not p.function_call and not p.function_response)


def _tem_anexo(parts) -> bool:
    return any(getattr(p, "inline_data", None) or getattr(p, "file_data", None) for p in parts or [])


def _aplicar() -> None:
    from google.adk.models import lite_llm as m
    from google.adk.flows.llm_flows import contents as fluxo
    from google.genai import types

    if getattr(m, "_evojud_audio_patch", False):
        return

    original_vazio = fluxo._contains_empty_content

    def _contains_empty_content(event):
        if not original_vazio(event):
            return False
        c = getattr(event, "content", None)
        return not (c is not None and c.role and _tem_anexo(c.parts))

    original_get_content = m._get_content

    def _get_content(parts, *args, **kwargs):
        out = original_get_content(parts, *args, **kwargs)
        if isinstance(out, list):
            for i, item in enumerate(out):
                if isinstance(item, dict) and item.get("type") == "audio_url":
                    out[i] = {"type": "file", "file": {"file_data": item["audio_url"]["url"]}}
        return out

    async def _ajustar(contents, modelo: str, api_key: str):
        gemini = "gemini" in modelo
        novos = []
        for c in contents or []:
            partes = list(c.parts or [])
            mudou = False
            for i, p in enumerate(partes):
                d = getattr(p, "inline_data", None)
                if d is None or not d.mime_type or not d.mime_type.lower().startswith("audio"):
                    continue
                mudou = True
                if gemini and d.data:
                    partes[i] = types.Part(inline_data=types.Blob(mime_type=_mime_gemini(d.mime_type), data=d.data))
                    continue
                texto = await _transcrever(d.data, d.mime_type, api_key) if _eh_openai(modelo) else None
                partes[i] = types.Part(text=PREFIXO_TRANSCRICAO + texto if texto else AVISO_SEM_AUDIO)
            if len(partes) > 1 and any(_parte_vazia(p) for p in partes):
                partes = [p for p in partes if not _parte_vazia(p)] or partes
                mudou = True
            novos.append(types.Content(role=c.role, parts=partes) if mudou else c)
        return novos

    original_generate = m.LiteLlm.generate_content_async

    async def generate_content_async(self, llm_request, stream: bool = False):
        modelo = str(getattr(llm_request, "model", None) or getattr(self, "model", "") or "").lower()
        api_key = str((getattr(self, "_additional_args", None) or {}).get("api_key") or "")
        llm_request.contents = await _ajustar(llm_request.contents, modelo, api_key)
        async for resposta in original_generate(self, llm_request, stream=stream):
            yield resposta

    fluxo._contains_empty_content = _contains_empty_content
    m._get_content = _get_content
    m.LiteLlm.generate_content_async = generate_content_async
    m._evojud_audio_patch = True
    _log.warning("evo-jud audio patch aplicado (google-adk LiteLlm)")


try:
    _aplicar()
except Exception as e:  # nunca impedir o processor de subir
    logging.getLogger("evojud.audio_patch").warning("evo-jud audio patch NÃO aplicado: %s", e)
