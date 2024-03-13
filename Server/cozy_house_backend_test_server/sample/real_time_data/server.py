from fastapi import FastAPI, WebSocket
import asyncio
import bson
import random

app = FastAPI()

@app.websocket("/ws")
async def data(websocket: WebSocket):
    await websocket.accept()

    while True:
        number = str(random.randint(0, 110))
        data = bson.dumps({"number": number})
        await websocket.send_bytes(data)
        await asyncio.sleep(0.2)
        

# 터미널에서 server 실행 
# 해당폴더에서 : uvicorn server:app --host 127.0.0.1 --port 5000
