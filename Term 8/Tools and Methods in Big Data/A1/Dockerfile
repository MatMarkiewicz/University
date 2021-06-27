FROM jupyter/scipy-notebook
WORKDIR /notebook
COPY . .
RUN pip install sparqlwrapper
CMD ["jupyter", "notebook", "--port=8888", "--no-browser",  "--ip=0.0.0.0", "--allow-root"]