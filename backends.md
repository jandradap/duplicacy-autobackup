Duplicacy currently supports local file storage, SFTP, WebDav and many cloud storage providers.

<details> <summary>Local disk</summary>

```
Storage URL:  /path/to/storage (on Linux or Mac OS X)
              C:\path\to\storage (on Windows)
```
</details>

<details> <summary>SFTP</summary>

```
Storage URL:  sftp://username@server/path/to/storage (path relative to the home directory)
              sftp://username@server//path/to/storage (absolute path)
```

Login methods include password authentication and public key authentication. You can set up SSH agent forwarding which is also supported by Duplicacy.

Public key authentication with signed certificate is also supported. That is, if the ssh private key file is `mykey`, Duplicacy will check if the signed certificate can be loaded from the file `mykey-cert.pub` under the same directory.

**Note for Synology users**
If the SFTP server is a Synology NAS, it is highly recommended to use the absolute path (the one with double slashes) in the storage url.  Otherwise, Synology's customized SFTP server may terminate the connections arbitrarily leading to frequent EOF errors.


</details>

<details> <summary>Dropbox</summary>

```
Storage URL:  dropbox://path/to/storage
```

For Duplicacy to access your Dropbox storage, you must provide an access token that can be obtained in one of two ways:
* Create your own app on the [Dropbox Developer](https://www.dropbox.com/developers) page, and then generate the [access token](https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/)
* Or authorize Duplicacy to access its app folder inside your Dropbox (following [this link](https://duplicacy.com/dropbox_start.html)), and Dropbox will generate the access token (which is not visible to us, as the redirect page showing the token is merely a static html hosted by Dropbox).  The actual storage folder will be the path specified in the storage url relative to the `Apps` folder.

</details>

<details> <summary>Amazon S3</summary>

```
Storage URL:  s3://amazon.com/bucket/path/to/storage (default region is us-east-1)
              s3://region@amazon.com/bucket/path/to/storage (other regions must be specified)
```

You'll need to input an access key and a secret key to access your Amazon S3 storage.

Minio-based S3 compatiable storages are also supported by using the `minio` or `minios` backends:
```
Storage URL:  minio://region@host/bucket/path/to/storage (without TLS)
Storage URL:  minios://region@host/bucket/path/to/storage (with TLS)
```

There is another backend that works with S3 compatible storage providers that require V2 signing:
```
Storage URL:  s3c://region@host/bucket/path/to/storage
```

</details>

<details>  <summary>Wasabi</summary>

```

Storage URL: 
            wasabi://us-east-1@s3.wasabisys.com/bucket/path
            wasabi://us-east-2@s3.us-east-2.wasabisys.com/bucket/path
            wasabi://us-west-1@s3.us-west-1.wasabisys.com/bucket/path
            wasabi://eu-central-1@s3.eu-central-1.wasabisys.com/bucket/path

```
Where `region` is the storage region, `bucket` is the name of the bucket and `path` is the path to the top of the Duplicacy storage within the bucket. Note that `us-west-1` additionally has the `region` in the host name but `us-east-1` does not.


[Wasabi](https://wasabi.com) is a relatively new cloud storage service providing a S3-compatible API.  It is well-suited for storing backups, because it is much cheaper than Amazon S3 with a storage cost of $0.0049/GB/month (see note below), and no additional charges on API calls and download bandwidth.

### S3 and Billing

#### Short Version

The `s3` storage backend renames objects with a copy and delete which is inexpensive for AWS but more expensive for Wasabi.  Use the `wasabi` backend for it to be handled properly.

#### Long Version

Wasabi's billing model differs from Amazon's in that any object created incurs charges for 90 days of storage, even if the object is deleted earlier than that, and then the monthly rate thereafter.

As part of the [process for purging data which is no longer needed](https://github.com/gilbertchen/duplicacy/wiki/Lock-Free-Deduplication#two-step-fossil-collection), Duplicacy renames objects.  Because S3 does not support renaming objects, Duplicacy's `s3` backend does the equivalent by using S3's copy operation to create a second object with the new name then deleting the one with the old name.  S3-style renaming with Wasabi will incur additional charges during fossilization because of the additional objects it creates.  For example, if a new 1 GB file is backed up in chunks on day 1, the initial storage will incur fees of at least $0.0117 (three months at $0.0039 each).  If the file goes away and all snapshots that contained it are pruned on day 50, renaming the chunks will create an additional 1 GB of objects with a newly-started 90-day clock at a cost of $0.0117.

The `wasabi` backend uses Wasabi's rename operation to avoid these extra charges.


### Snapshot Pruning

Wasabi's 90-day minimum for stored data means there is no financial incentive to reduce utilization through early pruning of snapshots.  Because of this, the strategy shown in the documentation for the [[prune]] command can be shortened to the following without incurring additional charges:

```
                                  # Keep all snapshots younger than 90 days by doing nothing
$ duplicacy prune -keep 7:90      # Keep 1 snapshot every 7 days for snapshots older than 90 days
$ duplicacy prune -keep 30:180    # Keep 1 snapshot every 30 days for snapshots older than 180 days
$ duplicacy prune -keep 0:360     # Keep no snapshots older than 360 days
```

</details>

<details>  <summary>DigitalOcean Spaces</summary>

```
Storage URL: s3://nyc3@nyc3.digitaloceanspaces.com/bucket/path/to/storage
```

[DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/) is a s3-compatible cloud storage provided by DigitalOcean.  The storage cost starts at $5 per month for 250GB and $0.02 for each additional GB.  DigitalOcean Spaces has the lowest bandwidth cost (1TB free per account and $0.01/GB additionally) among those who charge bandwidth fees.  There are no API charges which further lowers the overall cost.

Here is a tutorial on how to set up Duplicacy to work with DigitalOcean Spaces: https://www.digitalocean.com/community/tutorials/manage-backups-cloud-duplicacy
</details>


<details>  <summary>Google Cloud Storage</summary>

```
Storage URL:  gcs://bucket/path/to/storage
```

Starting from version 2.0.0, a new Google Cloud Storage backend is added which is implemented using the [official Google client library](https://godoc.org/cloud.google.com/go/storage).  You must first obtain a credential file by [authorizing](https://duplicacy.com/gcp_start) Duplicacy to access your Google Cloud Storage account or by [downloading](https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts) a service account credential file.

You can also use the s3 protocol to access Google Cloud Storage.  To do this, you must enable the [s3 interoperability](https://cloud.google.com/storage/docs/migrating#migration-simple) in your Google Cloud Storage settings and set the storage url as `s3://storage.googleapis.com/bucket/path/to/storage`.

</details>

<details> <summary>Microsoft Azure</summary>

```
Storage URL:  azure://account/container
```

You'll need to input the access key once prompted.

</details>

<details> <summary>Backblaze B2</summary>

```
Storage URL: b2://bucketname
```

You'll need to enter the account id and the master application key.  However, if you are using an application key to access your B2 account, you'll need to enter the application key id and the application key instead.

Backblaze's B2 storage is one of the least expensive (at 0.5 cent per GB per month, with a download fee of 1 cent per GB, plus additional charges for API calls).

Please note that if you back up multiple repositories to the same bucket, the [lifecyle rules](https://www.backblaze.com/b2/docs/lifecycle_rules.html) of the bucket is recommended to be set to `Keep all versions of the file` which is the default one.  The `Keep prior versions for this number of days` option will work too if the number of days is more than 7.

</details>

<details> <summary>Google Drive</summary>

```
Storage URL: gcd://path/to/storage (for My Drive)
             gcd://shareddrive@path/to/storage (for Shared Drive)
```

To use Google Drive as the storage, you first need to download a token file from https://duplicacy.com/gcd_start by authorizing Duplicacy to access your Google Drive, and then enter the path to this token file to Duplicacy when prompted.

Alternatively, you can [download](https://console.cloud.google.com/projectselector/iam-admin/serviceaccounts) a service account credential file which can be supplied to Duplicacy as a token file to access Google Drive.
</details>

<details> <summary>Microsoft OneDrive</summary>

```
Storage URL: one://path/to/storage (for OneDrive Personal)
             odb://path/to/storage (for OneDrive Business)
```

To use Microsoft OneDrive as the storage, you first need to download a token file from https://duplicacy.com/one_start or https://duplicacy.com/odb_start by authorizing Duplicacy to access your OneDrive, and then enter the path to this token file to Duplicacy when prompted.

</details>

<details> <summary>Hubic</summary>

```
Storage URL: hubic://path/to/storage
```

To use Hubic as the storage, you first need to download a token file from https://duplicacy.com/hubic_start by authorizing Duplicacy to access your Hubic drive, and then enter the path to this token file to Duplicacy when prompted.

Hubic offers the most free space (25GB) of all major cloud providers and there is no bandwidth charge (same as Google Drive and OneDrive), so it may be worth a try.

Note that hubic no longer allows the creation of new accounts.

</details>

<details> <summary>OpenStack Swift</summary>

```
Storage URL: swift://user@auth_url/container/path
```

If the storage requires more parameters you can specify them in the query string:

```
swift://user@auth_url/container/path?tenant=<tenant>&domain=<domain>
```

The following is the list of parameters accepted by the query string:

* domain
* domain_id
* user_id
* retries
* user_agent
* timeout
* connection_timeout
* region
* tenant
* tenant_id
* endpiont_type
* tenant_domain
* tenant_domain_id
* trust_id

This backend is implemented using https://github.com/ncw/swift.

</details>

<details> <summary>WebDav</summary>

```
Storage URL:  webdav://username@server/path/to/storage (path relative to the home directory)
              webdav://username@server//path/to/storage (absolute path)
```

</details>