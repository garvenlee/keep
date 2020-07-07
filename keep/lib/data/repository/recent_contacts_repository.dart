import 'package:keep/data/dao/recent_contacts_dao.dart';
import 'package:keep/models/recent_contacts.dart';

class RecentContactRepository {
  final rcDao = RecentDao();

  Future newRContact(RecentContact contact) => rcDao.newRecentContact(contact);

  Future newRGroup(RecentGroup group) => rcDao.newRecentGroup(group);

  Future getRecentContacts(int userId) => rcDao.getRecentContacts(userId);
}
