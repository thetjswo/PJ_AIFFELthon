import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    def __init__(self):
        """
            개발 환경에서 사용되는 환경 변수 목록 입니다.
            라즈베리파이 사용 시, 사용을 하지 않을 계획 입니다.
        """
        # 테스트 메세지
        self.TEST_MESSAGE = os.getenv('TEST_MESSAGE')
        # 웹캠 to 서버 url
        self.WEBCAM_TO_SERVER_URL = os.getenv('WEBCAM_TO_SERVER_URL')

        """
            실제 서비스에서 사용되는 환경 변수 목록 입니다.
        """
        # 디비 접속 정보
        self.DATABASE_URL = os.getenv('DATABASE_URL')
        # 로그 레벨 지정
        self.LOG_LEVEL = os.getenv('LOG_LEVEL')