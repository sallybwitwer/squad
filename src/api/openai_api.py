"""OpenAI API client for Squad."""

from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

_client: OpenAI | None = None


def get_client(api_key: str | None = None) -> OpenAI:
    """
    Return a shared OpenAI client.

    When ``api_key`` is omitted, the SDK uses ``OPENAI_API_KEY`` from the
    environment (see https://platform.openai.com/docs/api-reference/authentication).
    """
    global _client
    if api_key is not None:
        return OpenAI(api_key=api_key)
    if _client is None:
        _client = OpenAI(api_key=OPENAI_API_KEY)
    return _client


if __name__ == "__main__":
    client = get_client()
    print(client)