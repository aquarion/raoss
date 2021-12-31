FROM python:3

WORKDIR /usr/src/app

RUN pip install --no-cache-dir -r requirements.pip

CMD [ "python", "./sort_steam_screenshots.py" ]
