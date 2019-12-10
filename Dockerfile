FROM julia:1.3

# Here, we add the Joseki package to the docker container and then activate
# it as an environment.  Users should create a project that includes Joseki
# in Project.toml and add that to the container instead.

# Only add Project.toml, Manifest.toml, docker-simple.jl, and /src
ADD *.toml /Joseki/
ADD /examples /Joseki/examples
ADD /src /Joseki/src/
WORKDIR /Joseki

# Install dependencies
RUN julia -e 'using Pkg; pkg"activate ."; pkg"instantiate"'

CMD julia --project ./examples/docker-simple.jl
