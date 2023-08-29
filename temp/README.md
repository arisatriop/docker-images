No need to define Docker ENV if it's not crucial,
since it's very difficult to override it when the image
used for development. It's because we use 'clear_env = no' 
in PHP FPM, so we can't easily change those envs via .env.

Apfd Pecl extension is needed to make PHP handle Form Data 
correctly in HTTP Method other than POST. It's known limitation
of HTML form, which only possible to sent GET / POST request.
