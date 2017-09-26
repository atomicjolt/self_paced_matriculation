# Self Paced Matriculation
This plugin enables use of the [Canvas Enrollments API](https://canvas.instructure.com/doc/api/enrollments.html) to enroll individuals in "Self Paced" Courses.

## API Usage
Additional API paramaeters have been added to make this possible:
- `self_paced` - Boolean, default `false`.  When added to the parameters as `true` a `start_at` and `end_at` date are expected in the params and will be set on the enrollment to reflect personal course enrollment dates.  (See [Canvas Enrollments API](https://canvas.instructure.com/doc/api/enrollments.html) documentation for date formats on these parameters.)

## Installation
Clone this repo into the Canvas Plugins directory on your app server:
```sh
sysadmin@appserver:~$ cd /path/to/canvas/gems/plugins
sysadmin@appserver:/path/to/canvas/gems/plugins$ git clone https://github.com/atomicjolt/self_paced_matriculation.git
```

Now `bundle install` and `bundle exec rake canvas:compile_assets` and `rails server`.

After it is up, login with the site admin account and head over to the `/plugins` route (Navigated to by clicking `Admin -> Site Admin -> Plugins`).
Once there, scroll down to `Self Paced Matriculation` and click into it.  Enable the plugin.

You should be all set now. Enjoy!
