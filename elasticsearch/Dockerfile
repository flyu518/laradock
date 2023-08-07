ARG ELK_VERSION
FROM elasticsearch:${ELK_VERSION}

# TMD，上面那个在 FROM 之前，也只能在FROM之前生效，下面如果用就变成了空值，需要在FROM之后再定义一次，这个在定义之下到下一个FROM之前生效
ARG ELK_VERSION

# 安装中文分词插件，--batch是禁用插件交互模式
RUN elasticsearch-plugin install --batch https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ELK_VERSION}/elasticsearch-analysis-ik-${ELK_VERSION}.zip


EXPOSE 9200 9300
