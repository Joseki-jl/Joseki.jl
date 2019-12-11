FROM julia:1.3

# Unlike the dockerfile in the examples folder, this mimics the typical flow for a project that
# uses Joseki. 

RUN useradd --create-home --shell /bin/bash myuser
RUN mkdir /home/myuser/joseki_on_gcp

# Add files
COPY . /home/myuser/joseki_on_gcp/
WORKDIR /home/myuser/joseki_on_gcp

RUN chown myuser:myuser -R * \
    & chmod +x start_server.sh

USER myuser

# Install dependencies
RUN julia --project -e 'using Pkg; pkg"instantiate"; pkg"precompile"'
ENV JULIA_DEPOT_PATH "/home/myuser/.julia"

# Briefly run the server to trigger precompilation
RUN julia --project warmup.jl

CMD ["./start_server.sh"]
