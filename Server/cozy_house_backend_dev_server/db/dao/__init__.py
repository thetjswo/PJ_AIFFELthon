from sqlalchemy.orm import sessionmaker

from db import db_connector

Session = sessionmaker(bind=db_connector.engine)
session = Session()