import lyricsgenius as genius
import csv
import pandas as pd
import json
import billboard


alreadyScrapedArtist = []
with open('C:/Users/aidan/Desktop/datasets/lyrics.csv', mode='r') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for row in csv_reader:
        if not row[0].lower() in alreadyScrapedArtist:
            alreadyScrapedArtist.append(row[0].lower())
alreadyScrapedArtist.append('bradley cooper')
alreadyScrapedArtist.append('swae lee')
alreadyScrapedArtist.append('benny blanco')
alreadyScrapedArtist.append('michael buble')
alreadyScrapedArtist.append('j balvin')
alreadyScrapedArtist.append('beyonce')
alreadyScrapedArtist.append('cam')
alreadyScrapedArtist.append('ac/dc')

print(alreadyScrapedArtist)
artistList = []
year = 2016
numberYears = 10
songsPerArtist = 50

#Looping through n years of top 100 artists
for k in range(numberYears):
    stringYear = str(year)
    print("*******YEAR IS******** " + stringYear)
    tempDate = stringYear + '-01-20'
    artistChart = billboard.ChartData('artist-100', date = tempDate)
    year = year - 1

    #Looping through each artist on Billboard top 100

    for i in range(len(artistChart)):
        artist = artistChart[i].artist
        #Checking for repeated artists, or unwanted data (i.e., other languages)
        if artist in artistList:
            print(artist + ' already scraped')
            continue

        if artist == 'BTS':
            print('Skipping!')
            continue

        if artist.lower() in alreadyScrapedArtist:
            print(artist + ' already scraped')
            continue


        artistList.append(artist)

        api = genius.Genius('vBo209yP3bZ1d-4uQbpuWj93_0zVUyxC7OhB2XIwQNEy5Nqr6LAV1gM3RWwEiFVG')
        api.excluded_terms = ['(Remix)', '(Live)', '(Demo)', '(Mix)']
        api.remove_section_headers = True

        artist = api.search_artist(artist, max_songs=songsPerArtist, sort = 'popularity')
        try:
            lyrics = artist.save_lyrics()
            lyric_path = "C:/Users/aidan/Desktop/datasets/lyrics.csv"
            lyrics.keys()
            songs = lyrics.get('songs')
            lyric_df = pd.DataFrame(columns=['artist', 'name', 'lyrics'])

            for x in songs:
                lyric_df = lyric_df.append({
                    'artist': json.dumps(x.get('artist')).replace(',', ' ').replace('\'','').replace('\"','').replace('\\u200b', ''),
                    'name': json.dumps(x.get('title')).replace(',', ' ').replace('\'','').replace('\"','').replace('\\u200b', ''),
                    'lyrics': json.dumps(x.get('lyrics')).replace(',', ' ').replace('\'','').
                        replace('\"','').replace('\\n', ' ').replace('\\','').replace('.','').replace('(','').replace(')','')
                }, ignore_index=True)

            with open(lyric_path, 'a', newline='') as file:
                lyric_df.to_csv(file, index=False, header=False)
                lyric_df.iloc[0]
            print('done')
        except:
            continue

