(*!------------------------------------------------------------
 * [[APP_NAME]] ([[APP_URL]])
 *
 * @link      [[APP_REPOSITORY_URL]]
 * @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
 * @license   [[LICENSE_URL]] ([[LICENSE]])
 *------------------------------------------------------------- *)
//container.add('passwHash', TPbkdf2PasswordHashFactory.create());
container.add('passwHash', TArgon2iPasswordHashFactory.create());
//container.add('passwHash', TScryptPasswordHashFactory.create());
//container.add('passwHash', TSha2PasswordHashFactory.create().use512());
//container.add('passwHash', TSha2PasswordHashFactory.create().use256());
