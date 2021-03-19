FROM alpine:3.13 AS iperf3-build
WORKDIR /root
RUN apk add git alpine-sdk libtool pcc-libs-dev
RUN git clone https://github.com/esnet/iperf.git
WORKDIR /root/iperf
RUN git checkout 3.9
RUN ./bootstrap.sh
RUN sed -i 's/iperf3_profile_\(CFLAGS\|LDFLAGS\)\s*=\s*-pg -g/iperf3_profile_\1 = -g/' src/Makefile.am src/Makefile.in
RUN ./configure && make && make DESTDIR="`pwd`/tmp" install

FROM alpine:3.13 AS iperf3
COPY --from=iperf3-build /root/iperf/tmp/ /
RUN ldd /usr/local/bin/iperf3 && /usr/local/bin/iperf3 --version
EXPOSE 5201/UDP
EXPOSE 5201/TCP
ENTRYPOINT [ "/usr/local/bin/iperf3" ]
CMD [ "-s" ]
