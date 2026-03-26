# Squad

## Run everything (local development)

You need two processes: the FastAPI backend on port **8000**, and the Vite dev server for the React UI (default **5173**). Configure `DATABASE_URL` in `.env` (or your environment) so the API can connect to the database.

1. **API** — follow [Run the API](#run-the-api) below and leave `uvicorn` running.
2. **Web UI** — in another terminal, follow [Run the web UI](#run-the-web-ui).

The dev UI calls the API through a Vite proxy (`/api` → `http://127.0.0.1:8000`), so you do not need to set CORS or `VITE_API_URL` for local use unless you choose to.

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

3. Ensure `DATABASE_URL` is set (for example via a `.env` file in the project root, loaded by your shell or tooling).

4. Start the server:

   ```bash
   uvicorn squad.main:app --reload
   ```

   The API listens on [http://127.0.0.1:8000](http://127.0.0.1:8000). Open [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) for interactive OpenAPI docs, or [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health) for the health check.

To run without reload (for example production-style):

```bash
uvicorn squad.main:app --host 0.0.0.0 --port 8000
```

## Run the web UI

Requires [Node.js](https://nodejs.org/) (npm).

1. Install dependencies once:

   ```bash
   cd web
   npm install
   ```

2. Start the dev server:

   ```bash
   npm run dev
   ```

3. Open the URL shown in the terminal (usually [http://localhost:5173](http://localhost:5173)). The recruiters list and role matches expect the API to be running on port **8000**.

Optional: set `VITE_API_URL` (for example in `web/.env.local`) to point at a different API base URL. If unset in development, the app uses the `/api` proxy defined in `web/vite.config.ts`.

To build static assets for deployment:

```bash
cd web
npm run build
```

Output is written to `web/dist/`.
