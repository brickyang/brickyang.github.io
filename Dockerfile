FROM node:7

WORKDIR /blog

RUN npm install -g hexo-cli

EXPOSE 4000

CMD ["bash"]
