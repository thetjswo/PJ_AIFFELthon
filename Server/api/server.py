'''
websocket 활용해서 synchronous + asynchronous 기능 활용한 서버 구축
'''

import websockets   # websocket 모듈
import asyncio      # 비동기 프로그래밍을 위한 asyncio 모듈  

import cv2, base64  # OpenCV , base64 모듈

#TODO: 포트 번호 확인
# 포트 번호 설정
port = 5000
# 해당 포트에서 서버가 시작되었다는 문구 출력
print("Started server on port : ", port)

async def transmit(websocket, path):
    print("Client connected !") # Client 연결 확인 출력
    try :
        cap = cv2.VideoCapture(0)  # 카메라 영상을 가져오기 위해 VideoCapture 객체 생성

        while cap.isOpened():      # 카메라가 열려있는 동안 반복
            _, frame = cap.read()  # 카메라에서 frame 읽기

            # frame의 numpy array -> byte array 변환
            encoded = cv2.imencode('.jpg', frame)[1]

            # byte array -> base64 문자열로 인코딩
            # str으로 변환하는 이유 : python은 기본 byte object로 변환함
            data = str(base64.b64encode(encoded))
            
            # 앞뒤로 추가된 문자열 slicing해서 제거
            # python이 자동으로 byte 문자열 앞에 `b'`를, 뒤에는 끝나는(ending quote) 표시 추가함
            data = data[2:len(data)-1] 

            await websocket.send(data)  # websocket으로 데이터 전송 - await :전송 완료될떄까지 기다림

            # ## 디버깅용 코드
            # # 전송된 video feed 출력
            # cv2.imshow("Transmission", frame)

            # # `q` 키를 누르면 반복문 종료
            # if cv2.waitKey(1) & 0xFF == ord('q'):
            #     break

        cap.release() # 카메라 해제

    except websockets.connection.ConnectionClose as e:  # 웹소켓 연결이 닫히면
        print("Client Disconnected !") # 클라이언트 연결이 해제되었다고 메세지 출력
        cap.release() # 카메라 해제
        
    except:  # 이외의 예외 발생시
        print("Something went Wrong !") # 에러메세지 출력

# 웹소켓 서버 설정
## TODO: host 값 어떤 주소로 설정해야하는지 확인
## TODO: websockets.serve 하는 역할 찾기
start_server = websockets.serve(transmit, host="localhost", port=port)

# 비동기 이벤트 반복문 실행
asyncio.get_event_loop().run_until_complete(start_server)
# 비동기 이벤트 반복문이 계속 실행되도록 설정
asyncio.get_event_loop().run_forever()

            