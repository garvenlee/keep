# coding: utf8
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
from flask_mail import Message
import random
import string
import os


basedir = os.path.abspath(os.path.dirname(__file__))
app = Flask(__name__)
app.config['SECRET_KEY'] = "you don't know"
app.config['SQLALCHEMY_DATABASE_URI'] =\
    'sqlite:///' + os.path.join(basedir, 'data.sqlite')
app.config['SQLALCHEMY_COMMIT_ON_TEARDOWN'] = True
CORS(app, supports_credentials=True)

# app.config['MAIL_DEFAULT_SENDER'] = "271576355@qq.com"
sender_email = '271576355@qq.com'

db = SQLAlchemy(app)
mail = Mail(app)
mail.init_app(app)
db.Model.metadata.reflect(db.engine)


class User(db.Model):
    __tablename__ = 'Keep-Users'
    __table_args__ = {'extend_existing': True}
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(30))
    email = db.Column(db.String(30), unique=True, index=True)
    password = db.Column(db.String(15))
    api_key = db.Column(db.String(25), unique=True)

    def __repr__(self):
        return '<User %r>' % self.username


@app.route('/user/login', methods=['POST'])
def login():
    # data = request.get_json()
    data = request.form
    email = data.get('email')
    password = data.get('password')
    print(email, password)
    if email is not None and password is not None:
        user = User.query.filter_by(email=email, password=password).first()
        if user is not None:
            # email has been used to rehister.
            return jsonify({
                "error": False,
                "user": {
                    "username": user.username,
                    "email": email,
                    "password": password,
                    "api_key": user.api_key,
                },
            })
    # data convert err.
    return jsonify({"error": True, "error_msg": "Invalid credentitals"})


@app.route('/user/register', methods=['POST'])
def register():
    # data = request.get_json()
    data = request.form
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    print(email, password)
    if username is not None and email is not None and password is not None:
        user = User.query.filter_by(email=email).first()
        if user is not None:
            return jsonify({"error": True, "error_msg": "User has exist!"})
        else:
            api_key = generate_key()
            user = User(username=username, email=email,
                        password=password, api_key=api_key)
            db.session.add(user)
            db.session.commit()
            print('db create user success!')
            return jsonify({
                "error": False,
                "hint_msg": "You have registered successfully!"
            })
    return jsonify({"error": True, "error_msg": "Connected Error. Please check your network!"})


# 这里应该还要实现邮箱验证,注册时也应该有邮箱验证 // 之后再做
@app.route("/user/reset", methods=['POST'])
def reset():
    data = request.form
    email = data.get('email')
    password = data.get('password')
    user = User.query.filter_by(email=email).first()
    if user is not None:
        user.password = password
        db.session.add(user)
        db.session.commit()
        return jsonify({
            "error": False,
            "user": {
                "username": user.username,
                "email": email,
                "password": password,
                "api_key": user.api_key
            }
        })
    return jsonify({
        "error": True,
        "error_msg": "email is invalid!"
    })


@app.route("/user/forget", methods=['POST'])
def checkEmail():
    email = request.form.get('email')
    print(email)
    user = User.query.filter_by(email=email).first()
    if user is not None:
        code = generate_code()
        print(code)
        return {
            "error": False,
            "verification_code": code
        }
    # print('not user-----------------------------------------------')
    return jsonify({
        "error": True,
        "error_msg": "email is invalid!"
    })


def send_email(recipient, username, hintTxt):
    code = generate_code()
    msg = Message(hintTxt,
                  sender=("Me", sender_email),
        recipients=[recipient])
    with open('mail_template.txt', coding='utf8') as fs:
        msg.body = fs.readlines().format(username, code)
    mail.send(msg)

def generate_code():
    return ''.join(random.choice(string.digits) for _ in range(6))


def generate_key():
    cmd = True
    while cmd:
        api_key = ''.join(random.choice(
            string.ascii_letters + string.digits) for _ in range(25))
        if User.query.filter_by(api_key=api_key).first() is None:
            cmd = False
    return api_key


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=42300, debug=True)
    # app.run('localhost', port=42300, debug=True)
