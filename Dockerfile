FROM julia:0.6.2

# The julia base image doesn't have it's Pkg2 directory set up.  We do this now
# and also move it to a different folder that any user can write to.  When we
# actually run this on a service like Heroku it won't run under the root user.
RUN julia -e 'Pkg.init(); Pkg.add("HTTP"); Pkg.add("JSON")' \
 && mkdir /packages \
 && mkdir /packages/Joseki \
 && cp -R /root/.julia/v0.6/. /packages \
 && chmod -R a+rwx /packages

ENV JULIA_PKGDIR=/packages

COPY /examples/docker-simple.jl /server.jl
COPY /src /packages/Joseki/src

CMD julia /server.jl
