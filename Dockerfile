FROM ubuntu:21.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install --yes bzip2 cpio git wget && \
    apt-get clean

# install micromamba
RUN mkdir -p /software/micromamba && \
    cd /software/micromamba && \
    wget -qO- https://micromamba.snakepit.net/api/micromamba/linux-64/0.24.0 | tar -xvj bin/micromamba
ENV PATH="/software/micromamba/bin:${PATH}"

WORKDIR /cellxgene-vip
COPY ./VIP.yml .

RUN micromamba install --name base --file VIP.yml --root-prefix /software/micromamba --yes

ENV LIBARROW_MINIMAL=false
RUN R -q -e 'if(!require(devtools)) install.packages("devtools",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(Cairo)) devtools::install_version("Cairo",version="1.5-12",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(foreign)) devtools::install_version("foreign",version="0.8-76",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(ggpubr)) devtools::install_version("ggpubr",version="0.3.0",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(ggrastr)) devtools::install_version("ggrastr",version="0.1.9",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(arrow)) devtools::install_version("arrow",version="2.0.0",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(Seurat)) devtools::install_version("Seurat",version="3.2.3",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(rmarkdown)) devtools::install_version("rmarkdown",version="2.5",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(tidyverse)) devtools::install_version("tidyverse",version="1.3.0",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(viridis)) devtools::install_version("viridis",version="0.5.1",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(hexbin)) devtools::install_version("hexbin",version="1.28.2",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(ggforce)) devtools::install_version("ggforce",version="0.3.3",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(RcppRoll)) devtools::install_version("RcppRoll",version="0.3.0",repos = "http://cran.r-project.org")' && \
    R -q -e 'if(!require(fastmatch)) devtools::install_version("fastmatch",version="1.1-3",repos = "http://cran.r-project.org")' && \
    R -q -e 'if(!require(BiocManager)) devtools::install_version("BiocManager",version="1.30.10",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(fgsea)) BiocManager::install("fgsea")' && \
    R -q -e 'if(!require(rtracklayer)) BiocManager::install("rtracklayer")' && \
    R -q -e 'if(!require(rjson)) devtools::install_version("rjson",version="0.2.20",repos = "https://cran.us.r-project.org")' && \
    R -q -e 'if(!require(ComplexHeatmap)) BiocManager::install("ComplexHeatmap")' && \
    R -q -e 'if(!require(dbplyr)) devtools::install_version("dbplyr",version="1.0.2",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(RColorBrewer)) devtools::install_version("RColorBrewer",version="1.1-2",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(glue)) devtools::install_version("glue",version="1.4.2",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(gridExtra)) devtools::install_version("gridExtra",version="2.3",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(ggrepel)) devtools::install_version("ggrepel",version="0.8.2",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(MASS)) devtools::install_version("MASS",version="7.3-51.6",repos = "http://cran.us.r-project.org")' && \
    R -q -e 'if(!require(data.table)) devtools::install_version("data.table",version="1.13.0",repos = "http://cran.us.r-project.org")'

COPY . .

RUN ./config.sh

ENV RETICULATE_PYTHON="/software/micromamba/bin/python"

# CMD ["cellxgene", "launch", "--host", "0.0.0.0", "--port", "5005", "--disable-annotations", "/cellxgene-vip/cellxgene/example-dataset/pbmc3k.h5ad"]

RUN pip install cellxgene-gateway
ENV CELLXGENE_LOCATION=/software/micromamba/bin/cellxgene
ENV CELLXGENE_DATA=/cellxgene-data
ENV CELLXGENE_ARGS="--disable-annotations"

CMD ["cellxgene-gateway"]
