from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
from django.core.files.storage import FileSystemStorage
from lyricsMatch.semantic_search.unsupervised_search import search_lyrics
from django.template import RequestContext
from django.http import HttpResponse
from lyricsMatch.speech_process.speech_to_text import convert_to_text
from django.http import JsonResponse
# Create your views here.

def index(request):
    context_instance=RequestContext(request)
    template = loader.get_template('lyricsMatch/index.html')
    context = {'user_text': "This is a test"}
    return HttpResponse(template.render(context, request))


def find_lyrics(request):
    user_text = request.GET.get('user_text')
    returned_songs = search_lyrics(user_text)
    # < a href = "/polls/{{ question.id }}/" > {{question.question_text}} < / a >
    list_of_songs = []
    # list[0] sone name, list[1] singer name, list[2] youtube link
    for key in returned_songs:
        asong_list = returned_songs[key]
        song_name = asong_list[0]
        singer_name = asong_list[1]
        youtube_link = asong_list[2]
        first_entry = song_name + " - " + singer_name
        # html_code = "<a href = " + youtube_link + ">" + song_name + ", by" + singer_name+ "</a>"
        list_of_songs.append([first_entry, youtube_link])
    template = loader.get_template('lyricsMatch/index.html')
    context = {'list_of_songs': list_of_songs}
    return HttpResponse(template.render(context, request))


def save_audio_file(request):
    audio_file = request.body
    # fs = FileSystemStorage()
    f = open('audio.flac', 'wb')
    f.write(audio_file)
    f.close()
    # print('finish output')

    translation = convert_to_text('audio.flac')
    # print("We get here: " + translation)
    # return HttpResponse({'translation': 'success' + translation}, content_type="application/json")
    return JsonResponse({'translation': translation})

    # template = loader.get_template('lyricsMatch/index.html')
    # context = {'translated_text': translation}
    # return HttpResponse(template.render(context, request))
    #audio_file = request.FILES['audio']
    #print(audio_file.name)
    #fs = FileSystemStorage()
    #file_name = fs.save(audio_file.name, audio_file)
    #template = loader.get_template('lyricsMatch/index.html')
    #context = {'translated_text': "voice_to_text"}
    #return HttpResponse(template.render(context, request))



