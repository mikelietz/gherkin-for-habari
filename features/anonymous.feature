Feature: A working site
  In order to use Habari
  As an anonymous visitor
  I want to visit a site

Background:
  Given a Habari site is installed
  And there are multiple pages of content
  And I am not logged in

Scenario: Home page
  When I visit the home page
  Then I should see the home page

Scenario: Individual entry page
  When I visit the home page
  And I follow a link for a post title
  Then I should see the single entry page
  And I should see a comment form

Scenario: Comment
  When I visit the single entry page
  And I leave a valid comment
  Then I should see my comment

Scenario: Tag archive page
  When I visit the home page
  And I follow a link for a post's tag
  Then I should see the tag archive page
  And I should not see posts without the tag

Scenario: Admin
  When I visit the admin interface
  Then I should see the login page


