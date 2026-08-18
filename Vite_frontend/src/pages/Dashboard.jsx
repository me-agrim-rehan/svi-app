import { useNavigate } from 'react-router-dom'

import styles from './CSS/Dashboard.module.css'

function Dashboard() {
  const navigate = useNavigate()

  const cards = [
    {
      title: 'Users',
      description: 'View and manage registered users.',
      action: 'View Users',
      path: '/dashboard/users',
      icon: '👥',
    },
    {
      title: 'Jobs',
      description: 'Create and manage platform jobs.',
      action: 'View Jobs',
      path: '/dashboard/jobs',
      icon: '💼',
    },
    {
      title: 'Applications',
      description: 'View and manage job applications.',
      action: 'View Applications',
      path: '/dashboard/applications',
      icon: '📄',
    },
    {
      title: 'Admin Management',
      description: 'Manage administrators and permissions.',
      action: 'Manage Admins',
      path: '/dashboard/admins',
      icon: '⚙️',
    },
  ]

  return (
    <div className={styles.page}>

      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>
            Dashboard
          </h1>

          <p className={styles.subtitle}>
            Welcome to the admin panel.
          </p>
        </div>
      </div>


      <div className={styles.grid}>

        {cards.map((card) => (
          <div
            key={card.title}
            className={styles.card}
            onClick={() => navigate(card.path)}
          >

            <div className={styles.icon}>
              {card.icon}
            </div>

            <div className={styles.content}>

              <h2>
                {card.title}
              </h2>

              <p>
                {card.description}
              </p>

            </div>

            <div className={styles.action}>
              {card.action}
              <span>→</span>
            </div>

          </div>
        ))}

      </div>

    </div>
  )
}

export default Dashboard