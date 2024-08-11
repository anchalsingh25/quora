# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

# Creating users
users = User.create([
                      { name: 'Alice', email_id: 'alice@example.com',
                        password: 'test1test' },
                      { name: 'Bob', email_id: 'bob@example.com',
                        password: 'test1test' },
                      { name: 'Charlie', email_id: 'charlie@example.com',
                        password: 'test1test' },
                      { name: 'dummy', email_id: 'dummy@example.com',
                        password: 'dummy123dummy' }
                    ])

# Creating questions
questions = Question.create([
                              { title: 'What is Ruby on Rails?', description: 'Can someone explain what Ruby on Rails is?',
                                user_id: users.first.id },
                              { title: 'How to create a migration?', description: 'Steps to create a new migration in Rails.',
                                user_id: users.second.id }
                            ])

# Creating answers
answers = Answer.create([
                          { explanation: 'Ruby on Rails is a web application framework written in Ruby.', user_id: users.first.id,
                            question_id: questions.first.id },
                          { explanation: 'You can create a migration using the `rails generate migration` command.', user_id: users.second.id,
                            question_id: questions.second.id }
                        ])

# Creating comments
comments = Comment.create([
                            { content: 'Great explanation!', user_id: users.third.id, answer_id: answers.first.id },
                            { content: 'Thanks for the steps.', user_id: users.first.id, answer_id: answers.second.id }
                          ])

# Creating likes
likes = Like.create([
                      { likable_type: 'Answer', likable_id: answers.first.id, user_id: users.second.id },
                      { likable_type: 'Answer', likable_id: answers.second.id, user_id: users.third.id },
                      { likable_type: 'Comment', likable_id: comments.first.id, user_id: users.first.id },
                      { likable_type: 'Comment', likable_id: comments.second.id, user_id: users.second.id }
                    ])
