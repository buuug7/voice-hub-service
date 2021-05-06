create
database `voice_hub` default charset utf8mb4 collate utf8mb4_unicode_ci;

create table `users`
(
    id        varchar(255) not null primary key,
    name      varchar(255) not null,
    email     varchar(255) not null,
    password  varchar(255) not null,
    active    tinyint      not null default 1,
    loginFrom json         not null,
    createdAt datetime     not null,
    updatedAt datetime     not null,

    constraint `unique_users_email` unique (email)
);

create table `tags`
(
    id        varchar(255) not null primary key,
    name      varchar(255) not null,
    slug      varchar(255) not null,
    createdAt datetime     not null,
    updatedAt datetime     not null
);

create table `voice_files`
(
    id        varchar(255) not null primary key,
    uri       varchar(255) not null,
    meta      json         not null,
    createdAt datetime     not null,
    userId    varchar(255) not null,

    constraint `fk_voice_files_userId` foreign key (userId) references users (id)
)

create table `posts`
(
    id          varchar(255)  not null primary key,
    title       varchar(255)  not null,
    voice_text  varchar(1024) not null,
    active      tinyint       not null default 1,
    createdAt   datetime      not null,
    updatedAt   datetime      not null,
    userId      varchar(255)  not null,
    voiceFileId varchar(255)  not null,

    constraint `fk_posts_userId` foreign key (userId) references users (id),
    constraint `fk_posts_voiceFileId` foreign key (voiceFileId) references voice_files (id)
);

create table `replies`
(
    id          varchar(255) not null primary key,
    text        text         not null,
    active      tinyint      not null default 1,
    createdAt   datetime     not null,
    updatedAt   datetime     not null,
    postId      varchar(255) not null,
    userId      varchar(255) not null,
    voiceFileId varchar(255) not null,

    constraint `fk_replies_postId` foreign key (postId)
        references posts (id) on update cascade on delete no action,
    constraint `fk_replies_userId` foreign key (userId)
        REFERENCES users (id) on update cascade on delete no action,
    constraint `fk_replies_voiceFileId` foreign key (voiceFileId) references voice_files (id),
    constraint unique_postId_userId
        unique (postId, userId),

);

create table `posts_tags`
(
    postId varchar(255) not null,
    tagId  varchar(255) not null,

    primary key (postId, tagId),
    constraint `fk_posts_tags_postId` foreign key (postId)
        references posts (id) on update cascade on delete cascade,
    constraint `fk_posts_tags_tagId` foreign key (tagId)
        references tags (id) on update cascade on delete cascade
);

create table `replies_users_star`
(
    answerId varchar(255) not null,
    userId   varchar(255) not null,

    primary key (answerId, userId),
    constraint `fk_replies_users_star_answerId` foreign key (answerId)
        references replies (id) on update cascade on delete cascade,
    constraint `fk_replies_users_star_userId` foreign key (userId)
        references users (id) on update cascade on delete cascade
);

create table posts_users_watch
(
    postId varchar(255) not null,
    userId varchar(255) not null,

    primary key (postId, userId),
    constraint `fk_posts_users_watch_postId` foreign key (postId)
        references posts (id) on update cascade on delete cascade,
    constraint `fk_posts_users_watch_userId` foreign key (userId)
        references users (id) on update cascade on delete cascade
);
