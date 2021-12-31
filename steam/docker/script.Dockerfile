FROM python:3

WORKDIR /usr/src/app

COPY requirements.pip ./
RUN pip install --no-cache-dir -r requirements.pip

COPY . .

CMD [ "python", "./sort_steam_screenshots.py" ]
