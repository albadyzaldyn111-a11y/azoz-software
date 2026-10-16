<?php
declare(strict_types=1);

if ($route === 'client_quotes') {
    $u = \Azoz\Auth::requireAuth('client');
    $rows = q("SELECT q.*,r.title,cur.code FROM quotations q JOIN project_requests r ON r.id=q.request_id JOIN currencies cur ON cur.id=q.currency_id WHERE r.client_id=:c AND q.status='sent' ORDER BY q.created_at DESC", ['c'=>$u['id']]);
    $body = '<div class="page-heading"><h1>عروض الأسعار</h1></div><section class="card table-wrap"><table><tr><th>الطلب</th><th>الإصدار</th><th>المبلغ</th><th>المدة</th><th>الصلاحية</th><th>القرار</th></tr>';
    foreach ($rows as $r) $body .= '<tr><td>'.h($r['title']).'</td><td>'.h((string)$r['version_number']).'</td><td>'.h($r['total_amount'].' '.$r['code']).'</td><td>'.h($r['estimated_duration']).'</td><td>'.h($r['expires_at']).'</td><td>'.form('decide_quote','<input type="hidden" name="id" value="'.$r['id'].'"><select name="decision"><option value="accepted">قبول</option><option value="rejected">رفض</option></select><input name="note" placeholder="ملاحظة اختيارية">','حفظ القرار').'</td></tr>';
    page('عروض الأسعار',$body.'</table></section>',$u);
}

if ($route === 'decide_quote') {
    $u=\Azoz\Auth::requireAuth('client'); post_csrf(); $id=(int)$_POST['id'];
    $quote=one("SELECT q.*,r.client_id,r.title,r.description FROM quotations q JOIN project_requests r ON r.id=q.request_id WHERE q.id=:id AND r.client_id=:c AND q.status='sent' AND (q.expires_at IS NULL OR q.expires_at>NOW())",['id'=>$id,'c'=>$u['id']]);
    if (!$quote) { flash('error','العرض غير صالح أو منتهي.'); go('client_quotes'); }
    $decision=$_POST['decision']==='accepted'?'accepted':'rejected'; $db->beginTransaction();
    try {
        execq('INSERT INTO quotation_decisions(quotation_id,client_id,decision,decision_note) VALUES(:q,:c,:d,:n)',['q'=>$id,'c'=>$u['id'],'d'=>$decision,'n'=>trim((string)$_POST['note'])]);
        execq('UPDATE quotations SET status=:s WHERE id=:id',['s'=>$decision,'id'=>$id]);
        if ($decision==='accepted') { $admin=one("SELECT id FROM users WHERE role='admin' ORDER BY id LIMIT 1"); execq('INSERT INTO projects(request_id,quotation_id,client_id,name,description,status,created_by) VALUES(:r,:q,:c,:n,:d,"not_started",:a)',['r'=>$quote['request_id'],'q'=>$id,'c'=>$u['id'],'n'=>$quote['title'],'d'=>$quote['description'],'a'=>$admin['id']]); }
        $db->commit(); flash('ok',$decision==='accepted'?'تم قبول العرض وإنشاء المشروع.':'تم تسجيل رفض العرض.');
    } catch (Throwable $e) { if($db->inTransaction())$db->rollBack(); flash('error','تعذر حفظ القرار.'); }
    go('dashboard');
}

if ($route === 'invite') {
    $u=require_admin(); $error=null;
    if ($_SERVER['REQUEST_METHOD']==='POST') { post_csrf(); $email=strtolower(trim((string)$_POST['email'])); if(!filter_var($email,FILTER_VALIDATE_EMAIL)) $error='أدخل بريدًا صحيحًا.'; else { $raw=bin2hex(random_bytes(32)); execq('INSERT INTO developer_invitations(email,token_hash,invited_by,expires_at) VALUES(:e,:t,:u,DATE_ADD(NOW(),INTERVAL 7 DAY))',['e'=>$email,'t'=>hash('sha256',$raw),'u'=>$u['id']]); @file_put_contents(__DIR__.'/../storage/logs/mail.log',date('c')." developer invitation for {$email}: /?r=accept_invite&token={$raw}\n",FILE_APPEND); flash('ok','تم إنشاء الدعوة وسُجل رابطها في سجل البريد التجريبي.'); go('invite'); } }
    $rows=q('SELECT * FROM developer_invitations ORDER BY created_at DESC'); $body='<div class="page-heading"><h1>دعوات المطورين</h1></div><section class="card">'.($error?'<div class="error">'.h($error).'</div>':'').form('invite','<label>بريد المطور<input type="email" name="email" required></label>','إنشاء دعوة').'</section><section class="card table-wrap"><table><tr><th>البريد</th><th>الحالة</th><th>الانتهاء</th></tr>';
    foreach($rows as $r)$body.='<tr><td>'.h($r['email']).'</td><td>'.badge($r['status']).'</td><td>'.h($r['expires_at']).'</td></tr>';
    page('دعوات المطورين',$body.'</table></section>',$u);
}

if ($route === 'accept_invite') {
    if($user)go('dashboard'); $token=(string)($_GET['token']??$_POST['token']??''); $inv=one("SELECT * FROM developer_invitations WHERE token_hash=:t AND status='pending' AND expires_at>NOW()",['t'=>hash('sha256',$token)]);
    if(!$inv)page('دعوة غير صالحة','<section class="card narrow"><h1>الدعوة غير صالحة</h1><p>انتهت الدعوة أو تم استخدامها.</p></section>',$user);
    $error=null;
    if($_SERVER['REQUEST_METHOD']==='POST'){post_csrf();$name=trim((string)$_POST['full_name']);$pass=(string)$_POST['password'];if(strlen($pass)<8||strlen($name)<2)$error='تحقق من الاسم وكلمة المرور.';else{try{$db->beginTransaction();execq("INSERT INTO users(full_name,email,password_hash,role,status,email_verified_at) VALUES(:n,:e,:p,'developer','active',NOW())",['n'=>$name,'e'=>$inv['email'],'p'=>password_hash($pass,PASSWORD_DEFAULT)]);$uid=(int)$db->lastInsertId();execq("UPDATE developer_invitations SET status='accepted',accepted_by=:u,accepted_at=NOW() WHERE id=:id",['u'=>$uid,'id'=>$inv['id']]);$db->commit();page('تم إنشاء الحساب','<section class="card narrow"><h1>تم إنشاء حساب المطور</h1><a class="button button-primary" href="/login.php">تسجيل الدخول</a></section>',$user);}catch(Throwable $e){if($db->inTransaction())$db->rollBack();$error='تعذر إنشاء الحساب.';}}}
    $body='<section class="card narrow"><h1>قبول دعوة المطور</h1>'.($error?'<div class="error">'.h($error).'</div>':'').form('accept_invite','<input type="hidden" name="token" value="'.h($token).'"><label>الاسم الكامل<input name="full_name" required></label><label>كلمة المرور<input type="password" name="password" minlength="8" required></label>','إنشاء الحساب').'</section>'; page('قبول الدعوة',$body,$user);
}

if ($route === 'deliveries') {
    $u=require_user(); $rows=$u['role']==='admin'?q('SELECT d.*,p.name FROM deliveries d JOIN projects p ON p.id=d.project_id ORDER BY d.created_at DESC'):q('SELECT d.*,p.name FROM deliveries d JOIN projects p ON p.id=d.project_id WHERE p.client_id=:c ORDER BY d.created_at DESC',['c'=>$u['id']]);
    $body='<div class="page-heading"><h1>التسليمات</h1></div>'; if($u['role']==='admin')$body.='<section class="card">'.form('create_delivery','<label>معرف المشروع<input name="project_id" type="number" required></label><label>العنوان<input name="title" required></label><label>الوصف<textarea name="description" required></textarea></label>','إنشاء تسليم').'</section>';
    $body.='<section class="card table-wrap"><table><tr><th>المشروع</th><th>العنوان</th><th>الإصدار</th><th>الحالة</th><th>إجراء</th></tr>'; foreach($rows as $r)$body.='<tr><td>'.h($r['name']).'</td><td>'.h($r['title']).'</td><td>'.h((string)$r['version_number']).'</td><td>'.badge($r['status']).'</td><td>'.($u['role']==='client'&&$r['status']==='submitted'?form('approve_delivery','<input type="hidden" name="id" value="'.$r['id'].'">','اعتماد'):'').'</td></tr>'; page('التسليمات',$body.'</table></section>',$u);
}
if ($route === 'create_delivery') { $u=require_admin();post_csrf();$p=one('SELECT * FROM projects WHERE id=:id',['id'=>(int)$_POST['project_id']]);if($p){$v=one('SELECT COALESCE(MAX(version_number),0)+1 v FROM deliveries WHERE project_id=:p',['p'=>$p['id']]);execq("INSERT INTO deliveries(project_id,created_by,version_number,title,description,status,submitted_at) VALUES(:p,:u,:v,:t,:d,'submitted',NOW())",['p'=>$p['id'],'u'=>$u['id'],'v'=>$v['v'],'t'=>trim((string)$_POST['title']),'d'=>trim((string)$_POST['description'])]);}flash('ok','تم إنشاء التسليم.');go('deliveries'); }
if ($route === 'approve_delivery') { $u=\Azoz\Auth::requireAuth('client');post_csrf();$d=one('SELECT d.* FROM deliveries d JOIN projects p ON p.id=d.project_id WHERE d.id=:d AND p.client_id=:c',['d'=>(int)$_POST['id'],'c'=>$u['id']]);if($d)execq("UPDATE deliveries SET status='approved',approved_at=NOW() WHERE id=:id",['id'=>$d['id']]);flash('ok','تم اعتماد التسليم.');go('deliveries'); }

if ($route === 'add_member') { $u=require_admin(); post_csrf(); $project=(int)$_POST['project_id']; $developer=one("SELECT id FROM users WHERE id=:id AND role='developer' AND status='active'",['id'=>(int)$_POST['user_id']]); if($developer){execq('INSERT INTO project_members(project_id,user_id,assigned_by) VALUES(:p,:u,:a) ON DUPLICATE KEY UPDATE removed_at=NULL',['p'=>$project,'u'=>$developer['id'],'a'=>$u['id']]);flash('ok','تمت إضافة المطور إلى المشروع.');}else{flash('error','المستخدم ليس مطورًا فعالًا.');}go('project&id='.$project); }

if ($route === 'upload_file') {
    $u=require_user(); post_csrf(); $task=one('SELECT t.*,p.client_id FROM tasks t JOIN projects p ON p.id=t.project_id WHERE t.id=:id AND t.assigned_to=:u',['id'=>(int)$_POST['task_id'],'u'=>$u['id']]);
    if(!$task||empty($_FILES['attachment'])||$_FILES['attachment']['error']!==UPLOAD_ERR_OK){flash('error','تعذر رفع الملف.');go('dashboard');}
    $file=$_FILES['attachment']; $max=10*1024*1024; $allowed=['pdf','png','jpg','jpeg','doc','docx','xls','xlsx','zip']; $ext=strtolower(pathinfo((string)$file['name'],PATHINFO_EXTENSION));
    if((int)$file['size']>$max||!in_array($ext,$allowed,true)){flash('error','نوع الملف أو حجمه غير مسموح.');go('task&id='.$task['id']);}
    $finfo=new finfo(FILEINFO_MIME_TYPE);$mime=$finfo->file($file['tmp_name'])?:'application/octet-stream';$storage=bin2hex(random_bytes(20)).'.'.$ext;$dir=dirname(__DIR__).'/storage/private';if(!is_dir($dir))mkdir($dir,0700,true);$target=$dir.'/'.$storage;
    if(!move_uploaded_file($file['tmp_name'],$target)){flash('error','تعذر حفظ الملف.');go('task&id='.$task['id']);}
    execq('INSERT INTO files(uploaded_by,project_id,task_id,original_name,storage_name,storage_path,mime_type,file_size,checksum) VALUES(:u,:p,:t,:o,:s,:path,:m,:z,:c)',['u'=>$u['id'],'p'=>$task['project_id'],'t'=>$task['id'],'o'=>basename((string)$file['name']),'s'=>$storage,'path'=>$target,'m'=>$mime,'z'=>(int)$file['size'],'c'=>hash_file('sha256',$target)]);flash('ok','تم رفع الملف بأمان.');go('task&id='.$task['id']);
}
if ($route === 'download') {
    $u=require_user();$f=one('SELECT f.*,t.assigned_to,p.client_id FROM files f LEFT JOIN tasks t ON t.id=f.task_id LEFT JOIN projects p ON p.id=COALESCE(f.project_id,t.project_id) WHERE f.id=:id',['id'=>(int)($_GET['id']??0)]);$allowed=$f&&($u['role']==='admin'||($u['role']==='client'&&(int)$f['client_id']===(int)$u['id'])||($u['role']==='developer'&&(int)$f['assigned_to']===(int)$u['id']));if(!$allowed||!is_file($f['storage_path'])){http_response_code(404);exit('File not found');}header('Content-Type: '.$f['mime_type']);header('Content-Length: '.(string)$f['file_size']);header('Content-Disposition: attachment; filename="'.str_replace('"','',basename($f['original_name'])).'"');readfile($f['storage_path']);exit;
}
