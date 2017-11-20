## Run

$ git clone asmmon-web

$ cd asmmon-web

$ docker build -t asmmon-web .; docker stop asmmon-web; docker rm asmmon-web; docker run --name asmmon-web -d -p 3480:3000 asmmon-web
