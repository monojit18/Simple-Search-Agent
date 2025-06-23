FROM node:24

# Create app directory
WORKDIR /search-enginelib

COPY package*.json /search-enginelib/

RUN npm install --unsafe-perm

COPY . /search-enginelib/

EXPOSE 6080

CMD npm start