# Contributing

In the spirit of [free software], **everyone** is encouraged to help improve this project. Here are some ways *you* can contribute:

* Use alpha, beta, and pre-release versions.
* Report bugs.
* Suggest new features.
* Write or edit documentation.
* Write specifications.
* Write code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace).
* Refactor code.
* Fix [issues].
* Review patches.

[free software]: http://www.fsf.org/licensing/essays/free-sw.html
[issues]: https://github.com/michaelherold/ksuid-ruby/issues

## Submitting an Issue

We use the [GitHub issue tracker][issues] to track bugs and features. Before submitting a bug report or feature request, check to make sure it hasn't already been submitted.

When submitting a bug report, please include a [Gist](https://gist.github.com) that includes a stack trace and any details that may be necessary to reproduce the bug, including your gem version, Ruby version, and operating system.

Ideally, a bug report should include a pull request with failing specs.

## Submitting a Pull Request

1. [Fork the repository].
2. [Create a topic branch].
3. Add specs for your unimplemented feature or bug fix.
4. Run `appraisal rake spec`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `appraisal rake`. If your specs or any of the linters fail, return to step 5.
7. Open `coverage/index.html`. If your changes are not completely covered by your tests, return to step 3.
8. Add documentation for your feature or bug fix.
9. Commit and push your changes.
10. [Submit a pull request].

[Create a topic branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[Fork the repository]: http://learn.github.com/p/branching.html
[Submit a pull request]: https://help.github.com/articles/creating-a-pull-request/

## Tools to Help You Succeed

You will need a working copy of MySQL and PostgreSQL to run tests against them. At the root level of the gem, there is a `docker-compose.yml` file that sets up both of these services for you using either [Podman Compose](https://github.com/containers/podman-compose) or [Docker Compose](https://docs.docker.com/compose/). Both of these services will bind their default ports, so keep that in mind if you already have either database running on that port. Assuming you picked Podman, run:

    podman-compose up

in the `activerecord-ksuid` directory to start the services.

After checking out the repository, run `bin/setup` to install dependencies. Then, run `appraisal rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Before committing code, run `appraisal rake` to check that the code conforms to the style guidelines of the project, that all of the tests are green (if you're writing a feature; if you're only submitting a failing test, then it does not have to pass!), and that the changes are sufficiently documented.

[rubygems]: https://rubygems.org
