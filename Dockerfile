FROM alpine:3.10 AS iperf3-build
WORKDIR /root
RUN apk add git alpine-sdk libtool pcc-libs-dev
RUN git clone https://github.com/esnet/iperf.git
WORKDIR /root/iperf
RUN git checkout 3.7
RUN ./bootstrap.sh
RUN sed -i 's/iperf3_profile_\(CFLAGS\|LDFLAGS\)\s*=\s*-pg -g/iperf3_profile_\1 = -g/' src/Makefile.am src/Makefile.in
RUN ./configure --enable-static "LDFLAGS=--static" --disable-shared --without-openssl && make && mkdir tmp

FROM scratch
COPY --from=iperf3-build /root/iperf/src/iperf3 /iperf3
COPY --from=iperf3-build /root/iperf/tmp /tmp
EXPOSE 5201
ENTRYPOINT [ "/iperf3" ]
CMD [ "-s" ]
