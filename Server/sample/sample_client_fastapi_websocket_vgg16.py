import asyncio
import websockets
import json

async def websocket_client():
    async with websockets.connect("ws://127.0.0.1:5000/ws") as websocket:
        while True:
            data = await websocket.recv()
            if data.startswith("{") and data.endswith("}"):
                # 받은 데이터가 JSON 형식인 경우
                json_data = json.loads(data)
                print("Received JSON data:")
                print(json_data)
            else:
                # 받은 데이터가 텍스트인 경우
                print(f"Received data: {data}")

async def main():
    await websocket_client()

if __name__ == "__main__":
    asyncio.run(main())