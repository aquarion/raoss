FROM python:3

WORKDIR /usr/src/app

COPY ./sort_steam_screenshots.py /usr/src/app/

#RUN pip install --no-cache-dir -r /usr/src/app/requirements.pip
RUN pip install requests python-dotenv simplejson

CMD [ "python", "./sort_steam_screenshots.py", "/screenshots" ]
