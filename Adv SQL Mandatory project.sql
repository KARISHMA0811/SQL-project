-- 1.Create an ER diagram or draw a schema for the given database.

-- 2. We want to reward the user who has been around the longest, Find the 5 oldest users.
select * from users;
select id,username,date_format(created_at,'%d%M%Y') as create_date from users
order by created_at
limit 5;
-- 3.To understand when to run the ad campaign, figure out the day of the week most users register on? 
select dayname(created_at) as day,count(*)  from users
group by day
limit 1;
select max(dayname(created_at)) from users;
-- 4.To target inactive users in an email ad campaign, find the users who have never posted a photo.
select * from photos;
select id,username from users where id not in (select user_id from photos)
group by id; 
-- 5.Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
with likes_of_photo as
(select l.photo_id,count(l.user_id) as likes,p.user_id from likes l
join photos p on l.photo_id=p.id
group by photo_id,p.user_id)
select max(l.likes),l.user_id,u.username from likes_of_photo l inner join users u 
on l.user_id=u.id;

select username from users where id=52;
select user_id from photos where id=145;
-- 6.The investors want to know how many times does the average user post.
with cte as
(select user_id,count(id) as posts from photos
group by user_id)
select sum(posts)/count(*) as avg from cte;
-- 7.A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.
with cte as 
(select count(photo_id) as count, tag_id from photo_tags
group by tag_id)
select c.count,c.tag_id,t.tag_name from cte c inner join tags t
on c.tag_id=t.id
order by c.count desc limit 5;
-- 8.To find out if there are bots, find users who have liked every single photo on the site.
select username,id from users
where exists (select user_id from likes where users.id=likes.user_id group by photo_id)
group by id
order by id;
Create view Likes_of_photos as
select user_id, count(photo_id) as liked_photos from likes
group by user_id
order by count(photo_id) desc;
select * from likes_of_photos;
select u.username, lp.user_id, lp.liked_photos from users u
inner join likes_of_photos lp on u.id=lp.user_id
where lp.liked_photos in (select max(liked_photos) from likes_of_photos)
group by lp.user_id
order by liked_photos desc;
-- 9.To know who the celebrities are, find users who have never commented on a photo.
select * from comments;
select username,id from users  
where id not in (select user_id from comments)
group by id;
-- 10.Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo.
select * from comments;

Create view comments_of_photos as
select user_id, count(photo_id) as comments from comments
group by user_id
order by count(photo_id) desc;
select u.username, cp.user_id from users u
inner join comments_of_photos cp on u.id=cp.user_id
where cp.comments in (select max(comments) from comments_of_photos)
union all
select username,id as user_id from users
where id not in (select user_id from comments where users.id=comments.user_id)
group by id

union all
select c.user_id,u.username,c.comments from comments_of_photos c inner join users u
on c.user_id=u.id where c.comments not in (select max(comments) from comments_of_photos)
order by user_id;

SELECT username AS Username, COUNT(photo_id) AS Total
FROM comments
RIGHT JOIN users
ON users.id = comments.user_id
GROUP BY username
HAVING Total IN ((select COUNT(*) from photos), 0);

select username,id from users
where exists (select user_id from comments where users.id=comments.user_id)
group by id
union all
select username,id from users
where id not in (select user_id from comments)
group by id
order by id;
#get the all hash_tags comma seperated used on photo
select pt.photo_id,group_concat(t.tag_name) from photo_tags pt 
inner join tags t on pt.tag_id=t.id
group by pt.photo_id;

#get the average tags that has been done on a photo
select * from tags;
with cte as
(select count(tag_id) as counts ,photo_id from photo_tags
group by photo_id)
select sum(c.counts)/count(t.id) from cte c inner join tags t 
on t.id;

select u.id,count(p.id) as photos from users u join photos p
on u.id=p.user_id
group by p.user_id
having count(p.id) = (select count(*) from photos)
order by p.user_id;

-- Get the user with highest number of followers
select * from follows;
select followee_id , count(follower_id) from follows
group by followee_id
having count(follower_id)=5
order by count(follower_id) desc;
-- Get the users with 0 followers
select username,id from users 
where id not in ( select followee_id from follows)
group by id;

select * from
(select username,image_url,p.id as ph_id from users u
inner join photos p on u.id=p.user_id) g1
inner join
(select count(*) counts,photo_id from likes l
inner join photos p on p.id=l.photo_id
group by photo_id
order by counts desc
limit 1) g2
on g1.ph_id=g2.photo_id;

SELECT u.username,p.id,p.image_url,count(l.user_id) AS total
FROM photos p
INNER JOIN likes l ON l.photo_id=p.id
INNER JOIN users u ON p.user_id = u.id
GROUP BY p.id
ORDER BY total DESC
LIMIT 1;

SELECT users.username,photos.id,photos.image_url,
COUNT(*) AS Total_Likes
FROM likes
JOIN photos
ON photos.id = likes.photo_id
JOIN users
ON users.id = likes.user_id
GROUP BY photos.id
ORDER BY Total_Likes DESC
LIMIT 1;