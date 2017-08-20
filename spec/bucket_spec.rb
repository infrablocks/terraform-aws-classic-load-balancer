require 'spec_helper'
require 'pp'

describe 'Encrypted bucket' do
  let(:region) {vars.region}
  let(:bucket_name) {vars.bucket_name}

  subject {s3_bucket(bucket_name)}

  it {should exist}
  it {should have_versioning_enabled}
  it {should have_tag('Name').value("bucket-#{bucket_name}")}

  it 'is private' do
    expect(subject.acl_grants_count).to(eq(1))

    acl_grant = subject.acl.grants[0]
    expect(acl_grant.grantee.type).to(eq('CanonicalUser'))
    expect(acl_grant.permission).to(eq('FULL_CONTROL'))
  end

  it 'denies unencrypted object uploads' do
    policy = JSON.parse(
        find_bucket_policy(subject.id).policy.read)
    statements = policy['Statement']
    statement = statements.find do |s|
      s['Sid'] == 'DenyUnEncryptedObjectUploads'
    end

    expect(statement['Effect']).to(eq('Deny'))
    expect(statement['Principal']).to(eq('*'))
    expect(statement['Action']).to(eq('s3:PutObject'))
    expect(statement['Resource']).to(eq("arn:aws:s3:::#{bucket_name}/*"))
    expect(statement['Condition'])
        .to(eq(JSON.parse(
            '{"StringNotEquals": {"s3:x-amz-server-side-encryption": "AES256"}}')))
  end

  it 'denies unencrypted in flight operations' do
    policy = JSON.parse(
        find_bucket_policy(subject.id).policy.read)
    statements = policy['Statement']
    statement = statements.find do |s|
      s['Sid'] == 'DenyUnEncryptedInflightOperations'
    end

    expect(statement['Effect']).to(eq('Deny'))
    expect(statement['Principal']).to(eq('*'))
    expect(statement['Action']).to(eq('s3:*'))
    expect(statement['Resource']).to(eq("arn:aws:s3:::#{bucket_name}/*"))
    expect(statement['Condition'])
        .to(eq(JSON.parse(
            '{"Bool": {"aws:SecureTransport": "0"}}')))
  end

  it 'outputs the bucket name' do
    expect(output_with_name('bucket_name')).to(eq(bucket_name))
  end
end
