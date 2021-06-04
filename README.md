# RadarrRuby

This is a utility that loops across a set interval and checks for stalled or slow downloads with a setup including:

- Radarr
- Sonarr
- qBittorrent

## Disclaimer

This tool does not promote the use of tools used to illegally distribute content, and is being released for educational
purposes only. It also does not promote the distribution of illegal content, itself. Use at your own risk.

## What Does This Do?

Pushes slow or stalled downloads out the door after being queued by Sonarr or Radarr, which:

- Gets episodes and movies faster by potentially pulling in a faster download.
- Helps free up disk space.
- Can reduce local network congestion and CPU/memory load.

## Getting Started

1. Ensure you have `redis` and `ruby` (tested on 3.0.1) installed.
2. Clone this repository.
3. Install dependencies with `bundle` or `bundle install`.
4. `cp config_sample.yml config.yml` and alter as necessary.
5. Run `ruby init.rb -s` for Sonarr, or `ruby init.rb -r` for Radarr.
6. Profit.

## How Does It Work?

1. Asks qBittorrent for its download list.
2. Stores the states of each download in a Redis instance.
3. On next iteration, check states again and run through a "decision engine" of sorts.
4. If a download meets deletion criteria, find a matching queue item in Radarr/Sonarr, and blacklist it.
5. Repeat and profit.

## What Could Go Wrong?

1. Setting the interval to too short a time could trigger false positives, and get rid of reasonable downloads.
2. The same goes for setting the download speed threshold too low.
3. Being impatient about downloads, as this utility promotes one to be, isn't great for the peer-to-peer community.
4. You could be locked out of qBittorrent's API if you keep entering the wrong credentials. Oh yes, that's what I did.

## Why Did You Code X in File Y?

This started out as a tool to solidify my introduction into Ruby, so this is certainly not supposed to be a podium
example of how to code applications. It's publicly available for educational purposes only. Beware of the bugz!

## That Said...

Thank you for your time and attention. Happy coding!