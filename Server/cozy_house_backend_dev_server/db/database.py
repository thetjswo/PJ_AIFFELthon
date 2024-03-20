import sqlalchemy as db

from core import config

class DBConnector:
    def __init__(self):
        # MySQL 접속 URL
        self.database_url = config.DATABASE_URL

        # MySQL 접속 객체 생성
        self.engine = db.create_engine(self.database_url)
        self.connection = self.engine.connect()
        self.metadata = db.MetaData()