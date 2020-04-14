# Feedback Manager app

This application doesn't provide full interface, but represent the basic idea behind managing feedback in the concurrent environment.

## Task description
Imagine a small part of some project:
There is an Experience model, each experience has many feedback records and each feedback has many responses. They can be added and deleted.
Look at the file test_assignment.rb, it contains some DB schema details and active record models that are used. The DB contains thousands of experiences and hundreds of thousands of feedback records. One feedback record has many responses, some of them contain score info(how a user evaluate experience).

when you run SQL
`SELECT DISTINCT question FROM responses`
it returns:
- Let us know what you liked visited this experience
- Let us know what can be improved
- Rate the experience

when you run SQL
`SELECT DISTINCT answers FROM responses WHERE question = “Rate the 	experience”`
it returns:
- 5 great
- awesome (5)
- 4 OK
- 4
- not bad 3
- 2 bad
- 1 awful

Please provide a solution for each question below:

1. List all the issues(the bigger the best) related to DB structure and code described in the task and possible solution for each issue.
2. Implement #rating on the experience to return rating of the experience for example: experience.rating # => 4.33
	1. at first, implement the calculator on the fly and it should take an acceptable amount of the time and use server resources as less as possible(don’t change existing DB schema)
	2. then, provide a more efficient solution when the rating is stored in the experience model and is changed only on when the server receives feedback creation/destroy request (it requires changes fo the existing DB schema). This solution should work in the concurrent environment(lots of concurrent requests which add/delete feedback responses)
	3. describe the pros and cons of each solution implementation above
3. (Optional) Implement the app(similar to described in the task):
	1. it should contain a page with experiences list with rating info
	2. it should contain a page where user can create a new experience
	3. on the provider list page, the user can click button Leave Feedback and leave they feedback(they can’t see other feedback)
	4. the app doesn’t need any authentication you can limit feedback by IP address, 1 feedback is allowed for 1 IP
	5. the app should contain tests(model/controller unit tests)

## DB structure issues and possible solutions
1. **issue**: the absence of constraint for experience name column\
**solution**: add `null: false` constraint to the name column of the experiences table

2. **issue**: relatively slow joins of feedback and experiences tables. Inconstancy due to absence of the foreign key for experience in the feedback table.\
**solution**: add foreign key and index for the experience_id in the feedback table:\
`add_foreign_key :feedback, :experiences`\
`index_feedback_on_experience_id (experience_id)`


3. **issue**: inconsistency of the rating value. Having a separate question and answer for the ratings is wrong from the beginning because feedback will always contain a rating since it is coupled with other components of the application(experience) and reflected in the business logic. Absence of any database constraint for the rating leads to the usage of time-consuming database functions which will cover all possible values (example of sql query in task #2).\
**solution**: Add the rating column to the feedback table with DB constraints.
If only whole numbers are allowed the type should be an integer, in case we allow users to select “half star” like rating, float type would be more suitable.
It is better to have null value forbidden by constraint and it is better to not use default values for the rating column because it may affect avg experience rating.


4. **issue**: execution time of any operation with experiences rating will grow accordingly to the amount of experiences feedback.\
**solution**: add rating (float) column to the experiences table and appropriate index for it. It will store the cached avg rating number. Increased complexity should be kept in mind because it is needed to be recalculated every time when feedback record being added or removed.

5. **issue**: duplication of the question column value in the response table leads to performance degradation of the operations, which are utilize question column.\
**solution**:
the solution of this issue must match the level of configuration that the application is required.
	1. Questions are fixed and never will be changed:
use enum for the question column and add appropriate index for it.
	2. Questions should be configurable for every experience individually(suggested schema used in current project):
Add Question model with an appropriate table. Questions should be associated with experiences and responses should be associated with questions.

## Implement #rating on the experience to return rating of the experience

#### Implementation for existing schema
[commit with provided solution](https://github.com/nikitakhmelevskyi/feedback_manger/blob/faf37bc0bfb5cebb40eb1ffbee14f4179cdfb721/app/services/experience/rating_calculator.rb)

```ruby
class Experience::RatingCalculator
  QUESTION_IDENTIFIER = 'Rate the experience'.freeze
  QUERY = <<-SQL.freeze
    SELECT round(AVG(prepared_ratings.rating), 1) AS avg_rating
    FROM (
      SELECT NULLIF(regexp_replace(answer, '[^1-5]','','g'), '')::INTEGER AS rating
      FROM feedback
      INNER JOIN responses ON responses.feedback_id = feedback.id
      WHERE feedback.experience_id = '%{experience_id}'
      AND responses.question = '%{question_identifier}'
      AND responses.answer IS NOT NULL
    ) prepared_ratings
  SQL

  def self.call(experience)
    return if experience.blank?

    result = ActiveRecord::Base.connection.execute(
      QUERY % { experience_id: experience.id, question_identifier: QUESTION_IDENTIFIER }
    )

    result.first['avg_rating'].to_f if result.any?
  end
end
```

**pros**:
1. As no cache mechanism is used, no need to keep cached data actualized.

**cons**:
1. The absence of any database constraint for the rating leads to the usage of time-consuming database functions which will cover all possible values.
2. No acceptable way of using experience average rating as an attribute for sorting or filtering.
3. Hard to scale.

#### Implementation with modified DB structure and designed to work in the concurrent environment

This project presents a solution to the issues described above. It uses the async approach of triggering rating recalculation. Such behavior provided by `sidekiq` background job framework. Every time new feedback is added or removed new job to recalculate rating is created. In order to avoid triggering rating recalculation for the same experience multiple times in overlapping time periods `sidekiq-unique-jobs` gem is used. The same behavior could be achieved by `sidekiq enterprise` or any other self-made lock system.

**pros**:
1. Cached experience avg_rating doesn't require any runtime calculation, which makes it possible to sort and filter by it.
2. No need to lock experience records during feedback creation transactions to avoid the influence of other feedback creation/deletion requests.
3. Holds well during scaling.

**cons**:
1. The delay between adding feedback and updating experience average rating.
2. Background jobs are adding complexity and have their own points of failure.
