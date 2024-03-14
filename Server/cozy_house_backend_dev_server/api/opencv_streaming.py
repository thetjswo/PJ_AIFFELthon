import base64
import logging

import websockets
import asyncio
import cv2
import numpy as np

from core import config


async def receive_and_decode_video():

    async with websockets.connect(config.WEBCAM_TO_SERVER_URL) as websocket:
        try:
            while True:
                frame_data = await websocket.recv()
                frame_bytes = base64.b64decode(frame_data)
                frame_array = np.frombuffer(frame_bytes, dtype=np.uint8)

                frame = cv2.imdecode(frame_array, cv2.IMREAD_COLOR)

                #TODO: frame을 입력값으로 하는 모델 연동 필요

        except websockets.exceptions.ConnectionClosedError:
            logging.error('The connection to the server has been lost.')
        except Exception as e:
            logging.error(f'Error occurred: {e}')


async def main():
    await receive_and_decode_video()

if __name__ == "__main__":
    asyncio.run(main())