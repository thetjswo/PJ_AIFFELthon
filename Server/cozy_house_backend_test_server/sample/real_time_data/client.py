import asyncio
import websockets
import bson 

async def websocket_client():
    async with websockets.connect("ws://127.0.0.1:5000/ws") as websocket:
        for _ in range(5):  # Send and receive data for 5 iterations
            data_bytes = await websocket.recv()
            data = bson.loads(data_bytes)
            print(f"Received data: {data}")
            await asyncio.sleep(0.2)

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(websocket_client())