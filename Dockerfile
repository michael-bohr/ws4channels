FROM node:18

# Install FFmpeg, Puppeteer deps, and Intel GPU stack for QSV support
# The Intel .deb files are pre-downloaded to avoid SSL issues in build environment
# Pre-downloaded Intel GPU stack debs (v25/v2.22) for kernel 6.12 QSV support
COPY intel-media-va-driver-non-free_*.deb /tmp/
COPY libigdgmm12_*.deb /tmp/
COPY libmfx-gen1.2_*.deb /tmp/
COPY libva2_*.deb /tmp/
COPY libva-drm2_*.deb /tmp/
COPY libva-x11-2_*.deb /tmp/
RUN apt-get update && apt-get install -y \
  ffmpeg \
  libnss3 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcups2 \
  libdrm2 \
  libxkbcommon0 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  libgbm1 \
  libasound2 \
  && dpkg -i /tmp/libva2_*.deb /tmp/libva-drm2_*.deb /tmp/libva-x11-2_*.deb \
  && dpkg -i /tmp/libigdgmm12_*.deb \
  && dpkg -i /tmp/libmfx-gen1.2_*.deb \
  && apt-get remove -y intel-media-va-driver \
  && dpkg -i /tmp/intel-media-va-driver-non-free_*.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/*.deb

WORKDIR /app
COPY package*.json ./
RUN npm install --verbose

# Copy application code, music, and logo files
COPY . .
RUN mkdir -p /app/music /app/logo
COPY music/*.mp3 /app/music/
COPY logo/*.png /app/logo/

# Use STREAM_PORT environment variable for dynamic port
EXPOSE $STREAM_PORT
CMD ["node", "index.js"]

