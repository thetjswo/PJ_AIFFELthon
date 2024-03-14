import websockets
import asyncio

import cv2
import base64

import warnings

# 아래 경고 메세지만 무시
warnings.filterwarnings("ignore", 
                        message="AVCaptureDeviceTypeExternal is deprecated for Continuity Cameras*")

port = 5000

print("Started server on port : ", port)

async def transmit(websocket, path):
    print("Client Connected !")
    try :
        cap = cv2.VideoCapture(0) # connect to smartphone camera

        # 프레임 가로 크기 지정
        cap.set(3, 960)
        # 프레임 세로 크기 지정
        cap.set(4, 640)

        ret, frame = cap.read()

        if not ret:
            print('Error: Failed to capture frame...')
        else:
            while True:
                ret, frame = cap.read()
                cv2.imshow('video', frame)

                encoded = cv2.imencode('.jpg', frame)[1]

                data = str(base64.b64encode(encoded))
                data = data[2:len(data) - 1]  # 'b...'

                await websocket.send(data)

                # 입력되는 키를 k변수에 저장 - 1초마다 사용자 입력을 기다림
                k = cv2.waitKey(1) & 0xff1
                if k == 27:  # 27은 esc키 번호
                    # esc 키가 눌리면 프레임 읽기 종료
                    break
            
        cap.release()
        cv2.destroyAllWindows()
        
    except websockets.exceptions.ConnectionClosedError as e:
        print("Client Disconnected !")
        cap.release()
        cv2.destroyAllWindows()
    
    except Exception as e:
        print(f"Someting went Wrong: {e}")
        cap.release()
        cv2.destroyAllWindows()


start_server = websockets.serve(transmit, host="121.168.172.191", port=port)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()