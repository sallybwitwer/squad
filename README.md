# Squad

## Run the API

1. Create and activate a virtual environment (if you have not already):

   ```bash
   python -m venv .venv
   source .venv/bin/activate   # Windows: .venv\Scripts\activate
   ```

2. Install the project in editable mode:

   ```bash
   pip install -e .
   ```

3. Start the server:

   ```bash
   uvicorn squad.main:app --reload
   ```

   The API listens on [http://127.0.0.1:8000](http://127.0.0.1:8000). Open [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) for interactive OpenAPI docs, or [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health) for the health check.

To run without reload (e.g. production-style):

```bash
uvicorn squad.main:app --host 0.0.0.0 --port 8000
```
