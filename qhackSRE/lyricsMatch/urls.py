from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('/find_lyrics', views.find_lyrics, name='find_lyrics'),
    path('/audioupload', views.save_audio_file, name='save_audio_file'),
]
