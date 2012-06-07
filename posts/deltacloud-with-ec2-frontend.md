title: Deltacloud with EC2 frontend? Why not.
updated: 07/Jun/2012 10:50
###

We are doing the [Deltacloud API](http://deltacloud.org) project because we think that preventing from
vendor API lock-in is very important to everyone who uses services provided by a
public or private cloud vendor.
But what if you are already locked in to one particular cloud API? And yes, I am
speaking about the [Amazon EC2 API](http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/Welcome.html?r=7611)
which seems to by widely adopted. Since this API is
soo popular, the other projects like [OpenStack](https://github.com/yahoo/Openstack-EC2) or [Eucalyptus](http://www.eucalyptus.com/) provide an EC2 API
adaptor for those who are already locked by Amazon EC2.

In Deltacloud, we have our own API specification and in some case that could be a
deal breaker for some clients. Clients would need to change the code they already have
and start implementing our API standard. But this no longer true.

Deltacloud API now provides an **experimental support** for Amazon Elastic Compute
Cloud (2012-05-01) API as a frontend. Currently, only few "actions" are supported
but it is enough to run an instance in whatever backend cloud Deltacloud project
[supports](http://deltacloud.apache.org/drivers.html#providers).

To use EC2 frontend, you need to checkout the latest Deltacloud code from the GIT
repository. Then inside the <code>server/</code> directory run:

<code>$ bundle install </code>

<code>$ ./bin/deltacloud -i mock -f ec2</code>

Now, Deltacloud API should be running on port 3001 and you can start
experimenting:

<script src="https://gist.github.com/2888387.js?file=test.sh"></script>

So far these EC2 Actions are supported:

* DescribeAvailabilityZones
* DescribeImages
* DescribeInstances
* DescribeKeyPairs
* CreateKeyPair
* DeleteKeyPair
* RunInstances
* StopInstances
* StartInstances
* RebootInstances
* TerminateInstances

There are certain limitations currently which we will need to deal with in near
future. For now for example, you are not allowed to launch multiple instances
(__RunInstances__)
or do operations using multiple instance syntax (__InstanceId.n__). This frontend only works with one instance per request.
Another problem is that you cannot query for the __InstanceTypes__.
The reason for this is that EC2 Query API does not provide any "action" that can
list the supported instance types. For this, you will always need to "fallback"
to the Deltacloud API to obtain the list you can use for the _RunInstances_
operation.
