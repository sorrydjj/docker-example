FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN mkdir /app_name
WORKDIR /app_name

RUN apk update \
    && apk add postgresql gcc python3-dev musl-dev libffi-dev

#pipenv virtual enviroment
COPY Pipfile.lock /project_path
COPY Pipfile /project_path
RUN pip install pipenv
RUN pipenv install --system --deploy

#pip virtual enviroment
RUN pip install --upgrade pip
COPY requirements.txt /project_path
RUN pip install -r requirements.txt

COPY src /app_name/src
EXPOSE 8000

#uwsgi settings
COPY app_name/uwsgi.ini /etc/uwsgi/uwsgi.ini
RUN chown -R nobody:nogroup /app_name

#entrypoint settings
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

#run uwsgi
CMD ["uwsgi", "--ini", "/etc/uwsgi/uwsgi.ini"]
