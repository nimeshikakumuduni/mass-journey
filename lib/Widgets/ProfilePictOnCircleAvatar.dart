import 'package:flutter/material.dart';

class ProfilePictOnCircleAvatar extends StatefulWidget {
  final String creatorImageUrl;
  final double radius;
  ProfilePictOnCircleAvatar(this.creatorImageUrl, this.radius);
  @override
  State<StatefulWidget> createState() {
    return ProfilePictOnCircleAvatarState();
  }
}

class ProfilePictOnCircleAvatarState extends State<ProfilePictOnCircleAvatar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.creatorImageUrl != null
        ? 
        CircleAvatar(
          child: SizedBox(
            height: widget.radius*2,
            width: widget.radius*2,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              strokeWidth: 1,
              value: 1,
            ),
          ),
            radius: widget.radius,
            backgroundImage: NetworkImage(widget.creatorImageUrl),
          )
        : CircleAvatar(
          child: SizedBox(
            height: widget.radius*2,
            width: widget.radius*2,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              strokeWidth: 1,
              value: 1,
            ),
          ),
            radius: widget.radius,
            backgroundImage: AssetImage('assets/defaultProfilePicture.jpg'),
          );
  }
}
