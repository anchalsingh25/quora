# Creating Users
users = User.create!([
                       { name: 'Alice', email_id: 'alice@example.com', password: 'password123', user_role: 'reviewer' },
                       { name: 'Bob', email_id: 'bob@example.com', password: 'password123', user_role: 'user' },
                       { name: 'Charlie', email_id: 'charlie@example.com', password: 'password123', user_role: 'user' },
                       { name: 'Dave', email_id: 'dave@example.com', password: 'password123', user_role: 'admin' }
                     ])

# Creating Questions
questions = Question.create!([
                               { title: 'What is Ruby on Rails?', description: 'I want to know about Rails framework.',
                                 user: users[0] },
                               { title: 'How to seed data in Rails?', description: 'I am learning how to seed data.',
                                 user: users[1] },
                               { title: 'What is ActiveRecord?', description: 'Can someone explain ActiveRecord?',
                                 user: users[2] }
                             ])

# Creating Answers
answers = Answer.create!([
                           { explanation: 'Ruby on Rails is a server-side web application framework.', user: users[1],
                             question: questions[0] },
                           { explanation: 'You can seed data using the seeds.rb file.', user: users[2],
                             question: questions[1] },
                           {
                             explanation: 'ActiveRecord is the M in MVC - the model - which is the layer of the system responsible for representing business data and logic.', user: users[0], question: questions[2]
                           }
                         ])

# Creating Comments
comments = Comment.create!([
                             { content: 'Great explanation!', user: users[2], answer: answers[0] },
                             { content: 'This helped a lot.', user: users[0], answer: answers[1] },
                             { content: 'Thanks for the info!', user: users[1], answer: answers[2] }
                           ])

# Creating Punishments
punishments = Punishment.create!([
                                   { user: users[1], punishment_type: 'restricted_access',
                                     restriction_time: 1.day.from_now },
                                   { user: users[2], punishment_type: 'restricted_access',
                                     restriction_time: 2.days.from_now },
                                   { user: users[3], punishment_type: 'permanent_ban', restriction_time: nil }
                                 ])

# Creating Reports
reports = Report.create!([
                           { reportable: questions[0], reportee: users[0], reporter: users[1], category: 'spam',
                             reason: 'Irrelevant question' },
                           { reportable: answers[1], reportee: users[1], reporter: users[2], category: 'other',
                             reason: 'Inappropriate content' },
                           { reportable: comments[2], reportee: users[2], reporter: users[3], category: 'harassment',
                             reason: 'Offensive comment' }
                         ])

# Creating Likes
likes = Like.create([
                      { likable_type: 'Answer', likable_id: answers.first.id, user_id: users.second.id },
                      { likable_type: 'Answer', likable_id: answers.second.id, user_id: users.third.id },
                      { likable_type: 'Comment', likable_id: comments.first.id, user_id: users.first.id },
                      { likable_type: 'Comment', likable_id: comments.second.id, user_id: users.second.id }
                    ])
