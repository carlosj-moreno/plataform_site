# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class ChatAuthorizedlistentry(models.Model):
    id = models.BigAutoField(primary_key=True)
    placa = models.CharField(max_length=20)
    oficio_number = models.CharField(max_length=64)
    cedula = models.CharField(max_length=32)
    nombre = models.CharField(max_length=255)
    raw = models.JSONField()
    created_at = models.DateTimeField()
    bank = models.ForeignKey('ChatBank', models.DO_NOTHING, blank=True, null=True)
    company = models.ForeignKey('ChatCompany', models.DO_NOTHING)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    source_message = models.ForeignKey('ChatMessage', models.DO_NOTHING, blank=True, null=True)
    control_facturacion = models.JSONField(blank=True, null=True)
    cuadro = models.JSONField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_authorizedlistentry'


class ChatBank(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=120)
    code = models.CharField(max_length=30)
    is_active = models.BooleanField()
    created_at = models.DateTimeField()
    company = models.ForeignKey('ChatCompany', models.DO_NOTHING, blank=True, null=True)
    is_convenio = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'chat_bank'
        unique_together = (('name', 'company'),)


class ChatChatsession(models.Model):
    id = models.BigAutoField(primary_key=True)
    status = models.CharField(max_length=10)
    is_active = models.BooleanField()
    created_at = models.DateTimeField()
    archived_at = models.DateTimeField(blank=True, null=True)
    customer = models.ForeignKey('ChatCustomer', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_chatsession'


class ChatCompany(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=200)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'chat_company'


class ChatConversation(models.Model):
    id = models.BigAutoField(primary_key=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    customer = models.ForeignKey('ChatCustomer', models.DO_NOTHING)
    connection = models.ForeignKey('ChatWhatsappconnection', models.DO_NOTHING, blank=True, null=True)
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    session = models.ForeignKey(ChatChatsession, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_conversation'


class ChatCustomer(models.Model):
    id = models.BigAutoField(primary_key=True)
    phone_number = models.CharField(max_length=64)
    name = models.CharField(max_length=255, blank=True, null=True)
    is_bot_active = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    last_message = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=20)
    is_active = models.BooleanField()
    stage = models.CharField(max_length=20)
    last_updated_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    validation_status = models.CharField(max_length=20)
    case_label = models.CharField(max_length=20, blank=True, null=True)
    summary = models.TextField(blank=True, null=True)
    super_case = models.ForeignKey('ChatSupercase', models.DO_NOTHING, blank=True, null=True)
    assigned_to = models.ForeignKey(AuthUser, models.DO_NOTHING, related_name='chatcustomer_assigned_to_set', blank=True, null=True)
    region = models.CharField(max_length=120, blank=True, null=True)
    datos_extra = models.JSONField()
    review_status = models.CharField(max_length=10)
    is_package_complete = models.BooleanField()
    liquidation_requested_at = models.DateTimeField(blank=True, null=True)
    bank = models.ForeignKey(ChatBank, models.DO_NOTHING, blank=True, null=True)
    boss_approval_status = models.CharField(max_length=10)
    boss_approval_at = models.DateTimeField(blank=True, null=True)
    boss_decided_by = models.ForeignKey(AuthUser, models.DO_NOTHING, related_name='chatcustomer_boss_decided_by_set', blank=True, null=True)
    process_type = models.CharField(max_length=24)
    cost_responsibility = models.CharField(max_length=16)
    gate_status = models.CharField(max_length=24)
    departure_confirmed_at = models.DateTimeField(blank=True, null=True)
    departure_confirmed_by = models.ForeignKey(AuthUser, models.DO_NOTHING, related_name='chatcustomer_departure_confirmed_by_set', blank=True, null=True)
    salida_enabled_at = models.DateTimeField(blank=True, null=True)
    connection = models.ForeignKey('ChatWhatsappconnection', models.DO_NOTHING, blank=True, null=True)
    boss_approval_comment = models.TextField()
    salida_rejected_at = models.DateTimeField(blank=True, null=True)
    salida_rejected_by = models.ForeignKey(AuthUser, models.DO_NOTHING, related_name='chatcustomer_salida_rejected_by_set', blank=True, null=True)
    liquidation_client_notified_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_customer'
        unique_together = (('phone_number', 'company', 'connection'),)


class ChatCustomerTags(models.Model):
    id = models.BigAutoField(primary_key=True)
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)
    tag = models.ForeignKey('ChatTag', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_customer_tags'
        unique_together = (('customer', 'tag'),)


class ChatCustomercontext(models.Model):
    id = models.BigAutoField(primary_key=True)
    wa_id = models.CharField(max_length=30)
    context_key = models.CharField(max_length=50)
    created_at = models.DateTimeField()
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_customercontext'
        unique_together = (('wa_id', 'context_key'),)


class ChatDocumentvalidation(models.Model):
    id = models.BigAutoField(primary_key=True)
    status = models.CharField(max_length=20)
    comments = models.TextField()
    created_at = models.DateTimeField()
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)
    document = models.ForeignKey('ChatMessage', models.DO_NOTHING, blank=True, null=True)
    validator = models.ForeignKey(AuthUser, models.DO_NOTHING)
    document_type = models.CharField(max_length=30)
    source = models.CharField(max_length=12)

    class Meta:
        managed = False
        db_table = 'chat_documentvalidation'


class ChatExternaldatasource(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=100)
    url = models.CharField(max_length=500)
    method = models.CharField(max_length=4)
    auth_token = models.TextField(blank=True, null=True)
    auth_header_name = models.CharField(max_length=40)
    request_template = models.JSONField()
    extraction_prompt = models.TextField()
    timeout_seconds = models.SmallIntegerField()
    is_active = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    trigger_events = models.JSONField()
    required_fields = models.JSONField()
    dedup_enabled = models.BooleanField()
    alert_rules = models.JSONField()

    class Meta:
        managed = False
        db_table = 'chat_externaldatasource'
        unique_together = (('company', 'name'),)


class ChatExternallookuplog(models.Model):
    id = models.BigAutoField(primary_key=True)
    outcome = models.CharField(max_length=15)
    status_code = models.SmallIntegerField(blank=True, null=True)
    request_payload = models.JSONField()
    response_payload = models.JSONField()
    extracted = models.JSONField()
    error_detail = models.TextField()
    timestamp = models.DateTimeField()
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)
    requested_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    source = models.ForeignKey(ChatExternaldatasource, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_externallookuplog'


class ChatFactura(models.Model):
    id = models.BigAutoField(primary_key=True)
    fecha = models.DateField(blank=True, null=True)
    emisor = models.CharField(max_length=255)
    nit_emisor = models.CharField(max_length=40)
    receptor = models.CharField(max_length=255)
    nit_receptor = models.CharField(max_length=40)
    numero_factura = models.CharField(max_length=60)
    detalle = models.TextField()
    valor = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)
    cufe = models.CharField(max_length=120)
    qr_found = models.BooleanField()
    qr_raw = models.TextField()
    dian_email_ok = models.BooleanField()
    estado = models.CharField(max_length=12)
    confianza = models.SmallIntegerField()
    observaciones = models.TextField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING, blank=True, null=True)
    source_message = models.ForeignKey('ChatMessage', models.DO_NOTHING, blank=True, null=True)
    cuadro = models.JSONField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_factura'
        unique_together = (('company', 'cufe'),)


class ChatIntegrationkey(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(unique=True, max_length=120)
    hashed_key = models.CharField(unique=True, max_length=64)
    allowed_ips = models.JSONField()
    is_active = models.BooleanField()
    created_at = models.DateTimeField()
    last_used_at = models.DateTimeField(blank=True, null=True)
    usage_count = models.IntegerField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    owner = models.OneToOneField(AuthUser, models.DO_NOTHING, related_name='chatintegrationkey_owner_set', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_integrationkey'


class ChatIntegrationkeyusage(models.Model):
    id = models.BigAutoField(primary_key=True)
    endpoint = models.CharField(max_length=200)
    ip_address = models.GenericIPAddressField(blank=True, null=True)
    status_code = models.IntegerField()
    timestamp = models.DateTimeField()
    key = models.ForeignKey(ChatIntegrationkey, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_integrationkeyusage'


class ChatKanbanboard(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=120)
    description = models.TextField()
    color = models.CharField(max_length=7)
    is_default = models.BooleanField()
    is_archived = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_kanbanboard'


class ChatLiquidationvalidation(models.Model):
    id = models.BigAutoField(primary_key=True)
    cedula_original_confirmada = models.BooleanField()
    placa_confirmada_en_patios = models.BooleanField()
    placa_vehiculo = models.CharField(max_length=20)
    proceso_coincide_con_ingreso = models.BooleanField()
    proceso_coincide_nota = models.TextField()
    juez_ordena_entregar_a = models.CharField(max_length=12)
    banco_autoriza_a = models.CharField(max_length=255)
    instruccion_facturacion = models.TextField()
    autorizacion_banco_recibida = models.BooleanField()
    costo_ingreso = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)
    total_liquidacion = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)
    ajuste_grua_nota = models.TextField()
    banco_pagos_previos_conceptos = models.TextField()
    banco_pagos_previos_hasta = models.DateField(blank=True, null=True)
    validated_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    customer = models.OneToOneField(ChatCustomer, models.DO_NOTHING)
    validator = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    placa_patios_nota = models.TextField()
    oficio_veracidad_confirmada = models.BooleanField()
    oficio_veracidad_nota = models.TextField()

    class Meta:
        managed = False
        db_table = 'chat_liquidationvalidation'


class ChatMessage(models.Model):
    id = models.BigAutoField(primary_key=True)
    message_id = models.CharField(unique=True, max_length=255, blank=True, null=True)
    content = models.TextField()
    sender = models.CharField(max_length=20)
    timestamp = models.DateTimeField()
    conversation = models.ForeignKey(ChatConversation, models.DO_NOTHING)
    file = models.CharField(max_length=100, blank=True, null=True)
    message_type = models.CharField(max_length=10)
    ai_analysis = models.JSONField(blank=True, null=True)
    bundle_id = models.UUIDField(blank=True, null=True)
    internal = models.BooleanField()
    file_hash = models.CharField(max_length=64)
    oficio_number = models.CharField(max_length=64)
    author = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_message'


class ChatMovimientofinanciero(models.Model):
    id = models.BigAutoField(primary_key=True)
    tipo = models.CharField(max_length=20)
    monto = models.DecimalField(max_digits=12, decimal_places=2)
    descripcion = models.TextField()
    ubicacion = models.CharField(max_length=255)
    fecha_registro = models.DateTimeField()
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)
    session = models.ForeignKey(ChatChatsession, models.DO_NOTHING, blank=True, null=True)
    source_message = models.ForeignKey(ChatMessage, models.DO_NOTHING, blank=True, null=True)
    validated_at = models.DateTimeField(blank=True, null=True)
    validated_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    validation_status = models.CharField(max_length=10)

    class Meta:
        managed = False
        db_table = 'chat_movimientofinanciero'


class ChatReport(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=120)
    description = models.TextField()
    config = models.JSONField()
    is_pinned = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_report'
        unique_together = (('name', 'company'),)


class ChatReviewmessage(models.Model):
    id = models.BigAutoField(primary_key=True)
    body = models.TextField()
    created_at = models.DateTimeField()
    author = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    review = models.ForeignKey('ChatReviewrequest', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_reviewmessage'


class ChatReviewrequest(models.Model):
    id = models.BigAutoField(primary_key=True)
    description = models.TextField()
    status = models.CharField(max_length=10)
    comments = models.TextField()
    created_at = models.DateTimeField()
    decided_at = models.DateTimeField(blank=True, null=True)
    assigned_to = models.ForeignKey(AuthUser, models.DO_NOTHING)
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING)
    customer = models.ForeignKey(ChatCustomer, models.DO_NOTHING)
    requested_by = models.ForeignKey(AuthUser, models.DO_NOTHING, related_name='chatreviewrequest_requested_by_set', blank=True, null=True)
    kind = models.CharField(max_length=10)
    structured_response = models.JSONField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_reviewrequest'


class ChatSupercase(models.Model):
    id = models.BigAutoField(primary_key=True)
    title = models.CharField(max_length=200)
    category = models.CharField(max_length=30)
    description = models.TextField()
    status = models.CharField(max_length=20)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING)
    created_by = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    auto_created = models.BooleanField()
    last_interaction_at = models.DateTimeField(blank=True, null=True)
    target_phone = models.CharField(max_length=64)

    class Meta:
        managed = False
        db_table = 'chat_supercase'


class ChatTag(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=50)
    color = models.CharField(max_length=7)
    icon = models.CharField(max_length=10)
    created_at = models.DateTimeField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_tag'
        unique_together = (('name', 'company'),)


class ChatTimelineevent(models.Model):
    id = models.BigAutoField(primary_key=True)
    title = models.CharField(max_length=200)
    description = models.TextField()
    due_date = models.DateTimeField(blank=True, null=True)
    status = models.CharField(max_length=20)
    auto_created = models.BooleanField()
    source_quote = models.TextField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    assigned_to = models.ForeignKey(AuthUser, models.DO_NOTHING, blank=True, null=True)
    super_case = models.ForeignKey(ChatSupercase, models.DO_NOTHING, blank=True, null=True)
    position = models.IntegerField()
    board = models.ForeignKey(ChatKanbanboard, models.DO_NOTHING, blank=True, null=True)
    auto_assigned = models.BooleanField()
    priority = models.CharField(max_length=10)

    class Meta:
        managed = False
        db_table = 'chat_timelineevent'


class ChatUserprofile(models.Model):
    id = models.BigAutoField(primary_key=True)
    role = models.CharField(max_length=16)
    user = models.OneToOneField(AuthUser, models.DO_NOTHING)
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)
    last_checked_at = models.DateTimeField(blank=True, null=True)
    can_edit = models.BooleanField()
    dashboard_config = models.JSONField()
    permissions = models.JSONField()
    review_specialties = models.JSONField()
    zones = models.JSONField()
    bank = models.ForeignKey(ChatBank, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_userprofile'


class ChatWhatsappconnection(models.Model):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=100)
    connection_type = models.CharField(max_length=10)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    phone_number_id = models.CharField(max_length=100, blank=True, null=True)
    access_token = models.TextField(blank=True, null=True)
    session_id = models.CharField(unique=True, max_length=100, blank=True, null=True)
    status = models.CharField(max_length=20)
    session_duration_hours = models.IntegerField()
    created_at = models.DateTimeField()
    connected_at = models.DateTimeField(blank=True, null=True)
    last_seen_at = models.DateTimeField(blank=True, null=True)
    session_expires_at = models.DateTimeField(blank=True, null=True)
    disconnected_at = models.DateTimeField(blank=True, null=True)
    is_active = models.BooleanField()
    disconnect_count = models.IntegerField()
    last_error = models.TextField(blank=True, null=True)
    total_messages = models.IntegerField()
    cooldown_until = models.DateTimeField(blank=True, null=True)
    is_unstable = models.BooleanField()
    qr_code = models.TextField(blank=True, null=True)
    bot_active = models.BooleanField()
    allow_groups = models.BooleanField()
    company = models.ForeignKey(ChatCompany, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'chat_whatsappconnection'


class ChatWhatsappconnectionAssignedUsers(models.Model):
    id = models.BigAutoField(primary_key=True)
    whatsappconnection = models.ForeignKey(ChatWhatsappconnection, models.DO_NOTHING)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'chat_whatsappconnection_assigned_users'
        unique_together = (('whatsappconnection', 'user'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
