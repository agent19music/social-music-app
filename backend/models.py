"""
Database Models for Music Social Platform
Beautiful, scalable SQLAlchemy models with relationships
"""

from datetime import datetime
from typing import Optional, List
from sqlalchemy import func, Index
from sqlalchemy.dialects.postgresql import UUID, JSONB
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import uuid

from app import db


class BaseModel(db.Model):
    """Base model with common fields"""
    __abstract__ = True
    
    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert model to dictionary"""
        return {
            column.name: getattr(self, column.name)
            for column in self.__table__.columns
        }


class User(BaseModel):
    """User model with music preferences and social features"""
    __tablename__ = 'users'
    
    # Authentication
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    
    # Profile Information
    display_name = db.Column(db.String(100))
    bio = db.Column(db.Text)
    avatar_url = db.Column(db.String(500))
    cover_image_url = db.Column(db.String(500))
    date_of_birth = db.Column(db.Date)
    
    # Location
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    city = db.Column(db.String(100))
    country = db.Column(db.String(100))
    
    # Preferences
    social_preference = db.Column(db.String(50), default='stats_only')  # stats_only, open_to_meeting
    dating_enabled = db.Column(db.Boolean, default=False)
    dating_preferences = db.Column(JSONB, default={})  # age_range, gender, radius
    music_preferences = db.Column(JSONB, default={})  # genres, moods, eras
    
    # Music Platform Connections
    spotify_connected = db.Column(db.Boolean, default=False)
    spotify_data = db.Column(JSONB, default={})
    apple_music_connected = db.Column(db.Boolean, default=False)
    apple_music_data = db.Column(JSONB, default={})
    soundcloud_connected = db.Column(db.Boolean, default=False)
    soundcloud_data = db.Column(JSONB, default={})
    
    # Statistics
    total_listening_minutes = db.Column(db.Integer, default=0)
    total_songs_played = db.Column(db.Integer, default=0)
    streak_days = db.Column(db.Integer, default=0)
    last_active = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Referral System
    referral_code = db.Column(db.String(20), unique=True)
    referred_by_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'))
    referral_count = db.Column(db.Integer, default=0)
    
    # Relationships
    listening_history = db.relationship('ListeningHistory', backref='user', lazy='dynamic')
    badges = db.relationship('UserBadge', backref='user', lazy='dynamic')
    friendships = db.relationship('Friendship', 
                                 foreign_keys='Friendship.user_id',
                                 backref='user', lazy='dynamic')
    sent_messages = db.relationship('Message', 
                                   foreign_keys='Message.sender_id',
                                   backref='sender', lazy='dynamic')
    matches = db.relationship('Match',
                            foreign_keys='Match.user1_id',
                            backref='user1', lazy='dynamic')
    aux_wars_hosted = db.relationship('AuxWar', backref='host', lazy='dynamic')
    aux_war_submissions = db.relationship('AuxWarSubmission', backref='contestant', lazy='dynamic')
    
    def set_password(self, password: str):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password: str) -> bool:
        """Check if password matches"""
        return check_password_hash(self.password_hash, password)
    
    def __repr__(self):
        return f'<User {self.username}>'


class ListeningHistory(BaseModel):
    """Track user's listening history across platforms"""
    __tablename__ = 'listening_history'
    
    user_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    platform = db.Column(db.String(50), nullable=False)  # spotify, apple_music, etc
    
    # Song Information
    song_id = db.Column(db.String(255), nullable=False)  # Platform-specific ID
    song_title = db.Column(db.String(500), nullable=False)
    artist_name = db.Column(db.String(500), nullable=False)
    album_name = db.Column(db.String(500))
    album_art_url = db.Column(db.String(500))
    
    # Metadata
    duration_ms = db.Column(db.Integer)
    played_at = db.Column(db.DateTime, default=datetime.utcnow)
    play_count = db.Column(db.Integer, default=1)
    
    # Analytics
    genre = db.Column(db.String(100))
    mood = db.Column(db.String(100))
    energy_level = db.Column(db.Float)  # 0.0 to 1.0
    danceability = db.Column(db.Float)  # 0.0 to 1.0
    
    __table_args__ = (
        Index('idx_user_played_at', 'user_id', 'played_at'),
        Index('idx_user_artist', 'user_id', 'artist_name'),
    )


class Badge(BaseModel):
    """Achievement badges for milestones"""
    __tablename__ = 'badges'
    
    name = db.Column(db.String(100), unique=True, nullable=False)
    description = db.Column(db.Text)
    icon_url = db.Column(db.String(500))
    category = db.Column(db.String(50))  # listening, social, aux_wars, etc
    tier = db.Column(db.String(20))  # bronze, silver, gold, platinum
    points = db.Column(db.Integer, default=0)
    
    # Requirements
    requirement_type = db.Column(db.String(50))  # songs_played, friends_made, etc
    requirement_value = db.Column(db.Integer)


class UserBadge(BaseModel):
    """Track which badges users have earned"""
    __tablename__ = 'user_badges'
    
    user_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    badge_id = db.Column(UUID(as_uuid=True), db.ForeignKey('badges.id'), nullable=False)
    earned_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    badge = db.relationship('Badge', backref='user_badges')
    
    __table_args__ = (
        db.UniqueConstraint('user_id', 'badge_id'),
    )


class Friendship(BaseModel):
    """Friend connections between users"""
    __tablename__ = 'friendships'
    
    user_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    friend_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(20), default='pending')  # pending, accepted, blocked
    
    # Metadata
    compatibility_score = db.Column(db.Float)  # 0.0 to 100.0
    common_artists = db.Column(JSONB, default=[])
    common_genres = db.Column(JSONB, default=[])
    
    friend = db.relationship('User', foreign_keys=[friend_id])
    
    __table_args__ = (
        db.UniqueConstraint('user_id', 'friend_id'),
        Index('idx_friendship_status', 'status'),
    )


class Match(BaseModel):
    """Music-based matching between users"""
    __tablename__ = 'matches'
    
    user1_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    user2_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    
    # Matching Data
    compatibility_score = db.Column(db.Float, nullable=False)  # 0.0 to 100.0
    match_type = db.Column(db.String(50))  # weekly, proximity, manual
    status = db.Column(db.String(20), default='pending')  # pending, accepted, rejected
    
    # Swipe Data
    user1_action = db.Column(db.String(20))  # liked, passed, super_liked
    user2_action = db.Column(db.String(20))
    user1_swiped_at = db.Column(db.DateTime)
    user2_swiped_at = db.Column(db.DateTime)
    
    # Match Metadata
    matched_at = db.Column(db.DateTime)
    conversation_started = db.Column(db.Boolean, default=False)
    match_reasons = db.Column(JSONB, default={})  # common_artists, genres, etc
    
    user2 = db.relationship('User', foreign_keys=[user2_id])
    
    __table_args__ = (
        db.UniqueConstraint('user1_id', 'user2_id'),
        Index('idx_match_status', 'status'),
        Index('idx_match_score', 'compatibility_score'),
    )


class AuxWar(BaseModel):
    """Live music battle competitions"""
    __tablename__ = 'aux_wars'
    
    host_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    
    # Battle Configuration
    theme = db.Column(db.String(200))  # "90s Hip Hop", "Summer Vibes", etc
    max_contestants = db.Column(db.Integer, default=8)
    rounds = db.Column(db.Integer, default=1)
    current_round = db.Column(db.Integer, default=1)
    submission_time_limit = db.Column(db.Integer, default=120)  # seconds
    
    # Status
    status = db.Column(db.String(20), default='created')  # created, live, voting, completed
    started_at = db.Column(db.DateTime)
    ended_at = db.Column(db.DateTime)
    
    # Results
    winner_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'))
    total_votes = db.Column(db.Integer, default=0)
    
    # Relationships
    submissions = db.relationship('AuxWarSubmission', backref='aux_war', lazy='dynamic')
    votes = db.relationship('AuxWarVote', backref='aux_war', lazy='dynamic')
    
    winner = db.relationship('User', foreign_keys=[winner_id])


class AuxWarSubmission(BaseModel):
    """Song submissions for Aux Wars"""
    __tablename__ = 'aux_war_submissions'
    
    aux_war_id = db.Column(UUID(as_uuid=True), db.ForeignKey('aux_wars.id'), nullable=False)
    contestant_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    round_number = db.Column(db.Integer, default=1)
    
    # Song Information
    song_id = db.Column(db.String(255), nullable=False)
    song_title = db.Column(db.String(500), nullable=False)
    artist_name = db.Column(db.String(500), nullable=False)
    album_art_url = db.Column(db.String(500))
    preview_url = db.Column(db.String(500))
    
    # Voting
    vote_count = db.Column(db.Integer, default=0)
    
    __table_args__ = (
        db.UniqueConstraint('aux_war_id', 'contestant_id', 'round_number'),
    )


class AuxWarVote(BaseModel):
    """Votes for Aux War submissions"""
    __tablename__ = 'aux_war_votes'
    
    aux_war_id = db.Column(UUID(as_uuid=True), db.ForeignKey('aux_wars.id'), nullable=False)
    submission_id = db.Column(UUID(as_uuid=True), db.ForeignKey('aux_war_submissions.id'), nullable=False)
    voter_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    round_number = db.Column(db.Integer, default=1)
    
    submission = db.relationship('AuxWarSubmission', backref='votes')
    voter = db.relationship('User', backref='aux_war_votes')
    
    __table_args__ = (
        db.UniqueConstraint('aux_war_id', 'voter_id', 'round_number'),
    )


class Message(BaseModel):
    """Direct messages between users"""
    __tablename__ = 'messages'
    
    sender_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    recipient_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    
    # Content
    content = db.Column(db.Text, nullable=False)
    message_type = db.Column(db.String(20), default='text')  # text, sticker, song_share
    metadata = db.Column(JSONB, default={})  # sticker_id, song_data, etc
    
    # Status
    is_read = db.Column(db.Boolean, default=False)
    read_at = db.Column(db.DateTime)
    is_deleted = db.Column(db.Boolean, default=False)
    
    recipient = db.relationship('User', foreign_keys=[recipient_id])
    
    __table_args__ = (
        Index('idx_message_conversation', 'sender_id', 'recipient_id', 'created_at'),
    )


class SocialPost(BaseModel):
    """Social feed posts for music activities"""
    __tablename__ = 'social_posts'
    
    user_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    
    # Content
    post_type = db.Column(db.String(50), nullable=False)  # milestone, now_playing, playlist_share
    content = db.Column(db.Text)
    metadata = db.Column(JSONB, default={})  # song_data, milestone_data, etc
    
    # Engagement
    like_count = db.Column(db.Integer, default=0)
    comment_count = db.Column(db.Integer, default=0)
    share_count = db.Column(db.Integer, default=0)
    
    # Visibility
    visibility = db.Column(db.String(20), default='friends')  # public, friends, private
    
    user = db.relationship('User', backref='posts')
    reactions = db.relationship('PostReaction', backref='post', lazy='dynamic')


class PostReaction(BaseModel):
    """Reactions to social posts"""
    __tablename__ = 'post_reactions'
    
    post_id = db.Column(UUID(as_uuid=True), db.ForeignKey('social_posts.id'), nullable=False)
    user_id = db.Column(UUID(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    reaction_type = db.Column(db.String(50), nullable=False)  # like, love, fire, etc
    
    user = db.relationship('User', backref='reactions')
    
    __table_args__ = (
        db.UniqueConstraint('post_id', 'user_id'),
    )
