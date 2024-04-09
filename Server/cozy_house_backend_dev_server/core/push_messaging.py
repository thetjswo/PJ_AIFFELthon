import logging

import firebase_admin
from fastapi import HTTPException
from firebase_admin import credentials, messaging


class PushMessaging:
    _credentials = None
    _default_app = None

    @classmethod
    def get_credentials(cls):
        if cls._credentials is None:
            cls._credentials = credentials.Certificate(
                './resources/certs/cozy-house-1ecc7-firebase-adminsdk-tcckc-6f8d4bb07f.json')
        return cls._credentials

    @classmethod
    def get_default_app(cls):
        if cls._default_app is None:
            cls._default_app = firebase_admin.initialize_app(cls.get_credentials())
            logging.info(f'Firebase admin was initialized: {cls._default_app}')
        return cls._default_app



    def normal_push(self, fcm_token):

        if not fcm_token:
            raise HTTPException(status_code=400, detail="등록 토큰이 제공되지 않았습니다.")

        # 푸시 알림 메시지 생성
        message = messaging.Message(
            data={
                'title': '포근한 집',
                'body': '낯선 이가 집 근처를 배회하고 있습니다.\n앱을 실행한 뒤, 저장된 영상을 확인하세요.',
            },
            notification=messaging.Notification(
                title='포근한 집',
                body='낯선 이가 집 근처를 배회하고 있습니다.\n앱을 실행한 뒤, 저장된 영상을 확인하세요.',
            ),
            token=fcm_token,
        )

        try:
            # 푸시 알림 전송
            response = messaging.send(message)
            # TODO: push log 테이블에 데이터 추가
            return {"success": True, "message_id": response}
        except messaging.FirebaseMessagingError as e:
            # 오류 처리
            # TODO: push log 테이블에 데이터 추가
            raise HTTPException(status_code=500, detail=str(e))


    def caution_push(self, fcm_token):

        if not fcm_token:
            raise HTTPException(status_code=400, detail="등록 토큰이 제공되지 않았습니다.")

        # 푸시 알림 메시지 생성
        message = messaging.Message(
            data={
                'title': '포근한 집',
                'body': '낯선 이가 집 근처에서 수상한 행동을 하고 있습니다.\n앱을 실행한 뒤, 저장된 영상을 확인하세요.',
            },
            notification=messaging.Notification(
                title='포근한 집',
                body='낯선 이가 집 근처에서 수상한 행동을 하고 있습니다.\n앱을 실행한 뒤, 저장된 영상을 확인하세요.',
            ),
            token=fcm_token,
        )

        try:
            # 푸시 알림 전송
            response = messaging.send(message)
            # TODO: push log 테이블에 데이터 추가
            return {"success": True, "message_id": response}
        except messaging.FirebaseMessagingError as e:
            # 오류 처리
            # TODO: push log 테이블에 데이터 추가
            raise HTTPException(status_code=500, detail=str(e))


    def dangerous_push(self, fcm_token):

        if not fcm_token:
            raise HTTPException(status_code=400, detail="등록 토큰이 제공되지 않았습니다.")

        # 푸시 알림 메시지 생성
        message = messaging.Message(
            data={
                'title': '포근한 집',
                'body': '낯선 이가 주거침입을 시도하고 있습니다.\n저장된 영상을 확인한 뒤, 경찰에 신고하세요.',
            },
            notification=messaging.Notification(
                title='포근한 집',
                body='낯선 이가 주거침입을 시도하고 있습니다.\n저장된 영상을 확인한 뒤, 경찰에 신고하세요.',
            ),
            token=fcm_token,
        )

        try:
            # 푸시 알림 전송
            response = messaging.send(message)
            # TODO: push log 테이블에 데이터 추가
            return {"success": True, "message_id": response}
        except messaging.FirebaseMessagingError as e:
            # 오류 처리
            # TODO: push log 테이블에 데이터 추가
            raise HTTPException(status_code=500, detail=str(e))